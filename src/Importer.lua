local Cryo = require(script.Parent.lib.Cryo)
local t = require(script.Parent.lib.t)

local IConfig = t.strictInterface({
	aliases = t.map(t.string, t.instanceIsA("Instance")),
	useWaitForChild = t.boolean,
	waitForChildTimeout = t.number,
	detectRequireLoops = t.boolean,
	currentScriptAlias = t.string,
	dataModel = t.Instance,
})

local ALIAS_IS_ROBLOX_SERVICE = "Import: Alias '%s' is also defined as a Roblox service. Using alias instead."
local COULD_NOT_RESOLVE_PATH = "'%s' is not the name of a service, alias, or child of current dataModel (%s)"
local COULD_NOT_FIND_CHILD = "Could not find a child '%s' in \"%s\""

--[[
	Allows exporting individual members of a module.

	Usage:

		-- module.lua
		return { foo = "foo" }

		-- foo.server.lua
		local foo = getExports(module, { "foo" })
]]
local function getExports(moduleResult, exports, moduleFullName)
	local tuple = {}

	for _, name in ipairs(exports) do
		local export = moduleResult[name]
		assert(export, ("%s has no export named %s"):format(moduleFullName, name))
		table.insert(tuple, export)
	end

	return unpack(tuple)
end

--[[
	FindService and GetService both throw with invalid service names, so we
	wrap it in a pcall and pray.
]]
local function getIfService(name)
	local service
	pcall(function()
		service = game:FindService(name)
	end)
	return service
end

local Importer = {}
Importer.__index = Importer

function Importer.new(dataModel)
	local self = {}
	setmetatable(self, Importer)

	self._config = {
		aliases = {},
		useWaitForChild = false,
		waitForChildTimeout = 1,
		detectRequireLoops = true,
		currentScriptAlias = "script",
		dataModel = dataModel or game,
	}

	self._currentlyRequiring = {}

	assert(IConfig(self._config))

	return self
end

function Importer:isWaitingForRequire(module)
	for i, requiringModule in pairs(self._currentlyRequiring) do
		if requiringModule == module then
			return true, i
		end
	end
end

function Importer:buildRequireLoopPathString(startIndex, moduleName)
	local recursionPathStr = moduleName
	for i = startIndex + 1, #self._currentlyRequiring do
		local module = self._currentlyRequiring[i]
		recursionPathStr = recursionPathStr .. " - > " .. module.Name
	end
	recursionPathStr = recursionPathStr .. " - > " .. moduleName

	return recursionPathStr
end

function Importer:requireWithLoopDetection(module)
	local isWaiting, startIndex = self:isWaitingForRequire(module)

	-- If a require for a module hasn't completed when another module tries to
	-- require it, we know thatit's attempting to require modules in a loop.
	if isWaiting then
		local loopPath = self:buildRequireLoopPathString(startIndex, module.Name)
		error(("Require loop! %s"):format(loopPath))
	end

	-- Add the module we're attempting to require to the list of modules being
	-- required.
	table.insert(self._currentlyRequiring, module)

	-- Because requiring a module runs all the code in the module first before
	-- returning, any import calls that modulevau makes will run before require
	-- actually returns. Because of this, by adding the module to the list of
	-- requiring modules, we can build out a chain of dependencies. Once the
	-- deepest modules are required, the rcursion completes, and all the modules
	-- return their values, at which point we remove them from the currently
	-- requiring table.
	local result = require(module)

	-- Once the module has been required, we can remove it from the list of modules being required.
	for i = #self._currentlyRequiring, 1, -1 do
		if self._currentlyRequiring[i] == module then
			table.remove(self._currentlyRequiring, i)
			break
		end
	end

	return result
end

function Importer:setConfig(newValues)
	local newConfig = Cryo.Dictionary.join(self._config, newValues)

	assert(IConfig(newConfig))

	self._config = newConfig
end

function Importer:getChild(instance, childName)
	if self._config.useWaitForChild then
		local timeout = self._config.waitForChildTimeout
		return instance:WaitForChild(childName, timeout)
	end

	return instance:FindFirstChild(childName)
end

--[[
	Gets the next instance bawsed on the path part.

	This will either be ascending or descending depending on what the path part is.

	If hasAscendedParents is true, that menans we've already gone up by `../`
	before, and we need to switch how we ascend. `../` has to take us up to
	`script.Parent.Parent` to go up two levels, but if we use `../` again, we
	only expect to go up one more parent.
]]

local getNextInstanceCheck = t.tuple(t.Instance, t.string, t.boolean)
function Importer:getNextInstance(current, pathPart, hasAscendedParents, isFirstPart)
	assert(getNextInstanceCheck(current, pathPart, hasAscendedParents))

	if pathPart == self._config.currentScriptAlias then
		return current
	elseif pathPart == "." then
		return current.Parent
	elseif pathPart == ".." then
		if hasAscendedParents then
			return current.Parent
		else
			return current.Parent.Parent
		end
	else
		if isFirstPart then
			local alias = self._config.aliases[pathPart]
			local isService = self._config.dataModel == game and getIfService(pathPart) ~= nil

			if alias then
				if isService then
					warn(ALIAS_IS_ROBLOX_SERVICE:format(pathPart))
				end

				return alias
			elseif isService then
				return game:GetService(pathPart)
			else
				return self:getChild(self._config.dataModel, pathPart)
			end
		end

		return self:getChild(current, pathPart)
	end
end

local importCheck = t.tuple(t.instanceIsA("LuaSourceContainer"), t.string, t.optional(t.array(t.string)))

function Importer:import(callingScript, path, exports)
	assert(importCheck(callingScript, path, exports))

	local parts = path:split("/")
	local current = callingScript
	local hasAscendedParents = false
	local isFirstPart = true

	for _, pathPart in pairs(parts) do
		local nextInstance = self:getNextInstance(current, pathPart, hasAscendedParents, isFirstPart)

		if isFirstPart then
			assert(nextInstance, COULD_NOT_RESOLVE_PATH:format(pathPart, self._config.dataModel.Name))
		else
			assert(nextInstance, COULD_NOT_FIND_CHILD:format(pathPart, current:GetFullName(), pathPart))
		end
		-- This makes sure that `../` will take you up into the parent of the
		-- script (script.Parent.Parent), but `../../` will only take you up
		-- one extra parent after that.
		if pathPart == ".." then
			hasAscendedParents = true
		end

		current = nextInstance
		isFirstPart = false
	end

	if current:IsA("ModuleScript") then
		local result

		if self._config.detectRequireLoops then
			result = self:requireWithLoopDetection(current)
		else
			result = require(current)
		end

		if exports then
			return getExports(result, exports, current:GetFullName())
		else
			return result
		end
	else
		return current
	end
end

return Importer
