local Cryo = require(script.Parent.lib.Cryo)
local t = require(script.Parent.lib.t)

local IConfig = t.strictInterface({
	aliases = t.map(t.string, t.instanceIsA("Instance"))
})

--[[
	Allows exporting individual members of a module.

	Usage:

		-- module.lua
		return { foo = "foo" }

		-- foo.server.lua
		local foo = getExports(module, { "foo" })
]]
local function getExports(module, exports)
	local requiredModule = require(module)
	local tuple = {}

	for _, name in ipairs(exports) do
		local export = requiredModule[name]
		assert(export, ("%s has no export named %s"):format(module:GetFullName(), name))
		table.insert(tuple, export)
	end

	return unpack(tuple)
end


local Importer = {}
Importer.__index = Importer

function Importer.new(dataModel)
    local self = {}
    setmetatable(self, Importer)

	-- Allows you to mock the DataModel to be anything you want.
	self.dataModel = dataModel or game

	self._config = {
		aliases = {}
	}

	assert(IConfig(self._config))

    return self
end

function Importer:setConfig(newValues)
	local newConfig = Cryo.Dictionary.join(self._config, newValues)

	assert(IConfig(newConfig))

	self._config = newConfig
end

--[[
	Gets the next instance bawsed on the path part.

	This will either be ascending or descending depending on what the path part is.

	If hasAscendedParents is true, that menans we've already gone up by `../`
	before, and we need to switch how we ascend. `../` has to take us up to
	`script.Parent.Parent` to go up two levels, but if we use `../` again, we
	only expect to go up one more parent.
]]

local getNextInstanceCheck = t.tuple(
	t.Instance,
	t.string,
	t.boolean
)
function Importer:getNextInstance(current, pathPart, hasAscendedParents)
	assert(getNextInstanceCheck(current, pathPart, hasAscendedParents))

	if pathPart == "." then
		return current.Parent
	elseif pathPart == ".." then
		if hasAscendedParents then
			return current.Parent
		else
			return current.Parent.Parent
		end
	else
		local alias = self._config.aliases[pathPart]

		if alias then
			return alias
		else
			return current:FindFirstChild(pathPart)
		end
	end
end

local importCheck = t.tuple(
	t.instanceIsA("LuaSourceContainer"),
	t.string,
	t.optional(t.array(t.string))
)

function Importer:import(callingScript, path, exports)
	assert(importCheck(callingScript, path, exports))

	local parts = path:split("/")
	local current =  callingScript
	local hasAscendedParents = false

	for _, pathPart in pairs(parts) do
		local nextInstance = self:getNextInstance(current, pathPart, hasAscendedParents)

		-- This makes sure that `../` will take you up into the parent of the
		-- script (script.Parent.Parent), but `../../` will only take you up
		-- one extra parent after that.
		if pathPart == ".." then
			hasAscendedParents = true
		end

		assert(nextInstance, ("Could not find \"%s.%s\""):format(current:GetFullName(), pathPart))

		current = nextInstance
	end

	if current:IsA("ModuleScript") then
		if exports then
			return getExports(current, exports)
		else
			return require(current)
		end
	else
		return current
	end
end

return Importer
