--[[
	Combine a number of dictionary-like tables into a new table.

	Keys specified in later tables will overwrite keys in previous tables.
]]
local function join(...)
	local new = {}

	for i = 1, select("#", ...) do
		local source = select(i, ...)

		for key, value in pairs(source) do
			new[key] = value
		end
	end

	return new
end

return join
