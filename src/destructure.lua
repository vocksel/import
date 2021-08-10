local NOT_FOUND_ERROR = "Failed to destructure while importing (no export named %q found)"

local function destructure(object, members)
	local result = {}

	for _, memberName in ipairs(members) do
		local value = object[memberName]
		assert(value ~= nil, NOT_FOUND_ERROR:format(memberName))
		table.insert(result, value)
	end

	return table.unpack(result)
end

return destructure
