--[[
	Gets an instance based off the result of GetFullName().

	This is used in conjunction with debug.info() to locate the calling script.

	Returns nil if the instance is outside the DataModel.
]]

local Root = script:FindFirstAncestor("import")

local Sift = require(Root.Parent.Sift)

local PATH_SEPERATOR = "."

local function maybeGetService(serviceName: string): Instance?
	local success, current: any = pcall(function()
		-- Luau FIXME: TypeError: Type 'string' could not be converted into '"AdService"'
		return game:GetService(serviceName :: any)
	end)

	if success and current and current:IsA("Instance") then
		return current
	else
		return nil
	end
end

local function getInstanceFromFullName(fullName: string): Instance?
	local parts = fullName:split(PATH_SEPERATOR)
	local serviceName = table.remove(parts, 1)

	if serviceName then
		-- This function only works for instances in the DataModel. As such, the
		-- first part of the path will always be a service, so if we can't find
		-- one we exit out and return nil
		local current = maybeGetService(serviceName)

		if current then
			while #parts > 0 do
				-- Keep around a copy of the `parts` array. We are going to concat this
				-- into new paths, and incrementally remove from the right to narrow
				-- down the file path.
				local tempParts = Sift.Array.copy(parts)

				-- The result of GetFullName() uses dots to separate paths, but we also
				-- use dots in our file names (e.g. with spec and story files). As such,
				-- this block will look ahead to see if multiple parts are actually a
				-- single filename.
				for _ = 1, #tempParts do
					local name = table.concat(tempParts, PATH_SEPERATOR)
					local found = current:FindFirstChild(name)

					if found then
						current = found
						parts = Sift.List.shift(parts, #name:split(PATH_SEPERATOR))
						break
					else
						-- Reduce from the right until we find the next instance
						tempParts = Sift.List.pop(tempParts)
					end
				end
			end

			return current
		end
	end

	return nil
end

return getInstanceFromFullName
