local function splitPath(path: string, root: Instance)
	local parts = path:split("/")
	if parts[1] == "" then
		parts[1] = root
	end
	return parts
end

return splitPath
