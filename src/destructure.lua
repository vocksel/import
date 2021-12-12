--[[
	Allows exporting individual members of a module.

	Usage:

		-- module.lua
		return {
			foo = "foo"
		}

		-- foo.server.lua
		local foo = destructure(module, { "foo" })
]]

local NOT_FOUND_ERROR = "Failed to destructure while importing (no export named %q found)"

local function destructure(object: { [string]: any }, members: { string })
	local result = {}

	for _, memberName in ipairs(members) do
		local value = object[memberName]
		assert(value ~= nil, NOT_FOUND_ERROR:format(memberName))
		table.insert(result, value)
	end

	return table.unpack(result)
end

return destructure
