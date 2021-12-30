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

local function prettyPcall(callback, ...)
	local error, traceback
	local function xpcallInternalErrHandler(internalError)
		-- xpcall error handler can only return one value out from the call, so
		-- we use upvalues to pass the error and traceback out of the xpcall
		-- without lots of ugly overcomplicated packing and unpacking.
		error = internalError
		traceback = debug.traceback(nil, 2) or "nil"
	end

	local results = table.pack(xpcall(callback, xpcallInternalErrHandler, ...))

	if results[1] == false then
		return false, error, traceback
	else
		return true, table.unpack(results, 2, results.n)
	end
end

function wrapInCurlies(str)
	if str:find("\n") ~= nil then
		str = str:gsub("\n", "\n  ") -- Indent every newline by 2 spaces
		return string.format("{\n  %s\n}", str) -- Wrap indented text block in curly brackets
	else
		return string.format("{ %s }", str)
	end
end

function formatError(err, traceback)
	return wrapInCurlies(
		string.format("Error: %s\nTraceback: %s", wrapInCurlies(tostring(err)), wrapInCurlies(traceback))
	)
end

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
		if not export then
			error(string.format("'%s' has no export named '%s'", moduleFullName, name), 4)
		end
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

	self._hasReloaded = false
	self._reloadedModules = {}
	self._originalModules = {}
	self._reloadLocations = {}

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
	-- require it, we know that it's attempting to require modules in a loop.
	if isWaiting then
		local loopPath = self:buildRequireLoopPathString(startIndex, module.Name)
		error(("Require loop! %s"):format(loopPath), 4)
	end

	-- Add the module we're attempting to require to the list of modules being
	-- required.
	table.insert(self._currentlyRequiring, module)

	-- Because requiring a module runs all the code in the module first before
	-- returning, any import calls that module makes will run before require
	-- actually returns. Because of this, by adding the module to the list of
	-- requiring modules, we can build out a chain of dependencies. Once the
	-- deepest modules are required, the rcursion completes, and all the modules
	-- return their values, at which point we remove them from the currently
	-- requiring table.
	local result

	local success, errorMsg, traceback = prettyPcall(function()
		result = require(module)
	end)

	if not success then
		error(string.format("Module '%s' errored on require: \n%s", module.Name, formatError(errorMsg, traceback)), 4)
	end

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

	current = self._originalModules[current] or current

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
					warn(
						("Import: Alias '%s' is also defined as a Roblox service. Using alias instead."):format(
							pathPart
						)
					)
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

local bindToChangesInLocationsCheck = t.tuple(t.table, t.callback)
function Importer:bindToChangesInLocations(locations, callback)
	assert(bindToChangesInLocationsCheck(locations, callback))

	for _, location in ipairs(locations) do
		table.insert(self._reloadLocations, location)

		location.DescendantAdded:Connect(function()
			self._hasReloaded = true
			self._reloadedModules = {}
			self._originalModules = {}
			callback()
		end)
		location.DescendantRemoving:Connect(function()
			self._hasReloaded = true
			self._reloadedModules = {}
			self._originalModules = {}
			callback()
		end)

		for _, descendant in pairs(location:GetDescendants()) do
			if descendant:IsA("ModuleScript") then
				descendant.Changed:Connect(function(property)
					if property == "Source" then
						self._hasReloaded = true
						self._reloadedModules = {}
						self._originalModules = {}
						callback()
					end
				end)
			end
		end
	end
end

local function isDescendantOfAnyAncestors(instance, potentialAncestors)
	for _, ancestor in ipairs(potentialAncestors) do
		if instance:IsDescendantOf(ancestor) or instance == ancestor then
			return true
		end
	end

	return false
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

		if isFirstPart and not nextInstance then
			error(
				string.format(
					"'%s' is not the name of a service, alias, or child of current dataModel (%s)",
					pathPart,
					self._config.dataModel.Name
				),
				3
			)
		else
			error(string.format("Could not find a child '%s' in \"%s\"", pathPart, current:GetFullName()), 3)
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

	if self._hasReloaded and isDescendantOfAnyAncestors(current, self._reloadLocations) then
		if not self._reloadedModules[current] then
			local clone = current:Clone()
			self._reloadedModules[current] = clone
			self._originalModules[clone] = current
		end

		current = self._reloadedModules[current]
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
