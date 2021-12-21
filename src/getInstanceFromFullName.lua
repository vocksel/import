--[[
	Gets an instance based off the result of GetFullName().

	This is used in conjunction with debug.info() to locate the calling script.

	Returns nil if the instance is outside the DataModel.
]]

local Llama = require(script.Parent.Parent.Llama)

local PATH_SEPERATOR = "."

local function getInstanceFromFullName(fullName: string): Instance?
	local parts: { string } = fullName:split(PATH_SEPERATOR)
	local serviceName = table.remove(parts, 1)

	local success, current = pcall(function()
		return game:GetService(serviceName)
	end)

	-- This function only works for instances in the DataModel. As such, the
	-- first part of the path will always be a service. If we cannot get a
	-- service from the first part of the path, simply return nil
	if not (success and current) then
		return nil
	end

	while #parts > 0 do
		-- Keep around a copy of the `parts` array. We are going to concat this
		-- into new paths, and incrementally remove from the right to narrow
		-- down the file path.
		local tempParts = Llama.List.copy(parts)

		-- The result of GetFullName() uses dots to separate paths, but we also
		-- use dots in our file names (e.g. with spec and story files). As such,
		-- this block will look ahead to see if multiple parts are actually a
		-- single filename.
		for _ = 1, #tempParts do
			local name = table.concat(tempParts, PATH_SEPERATOR)
			local found = current:FindFirstChild(name)

			if found then
				current = found
				parts = Llama.List.shift(parts, #name:split(PATH_SEPERATOR))
				break
			else
				-- Reduce from the right until we find the next instance
				tempParts = Llama.List.pop(tempParts)
			end
		end
	end

	return current
end

return getInstanceFromFullName
