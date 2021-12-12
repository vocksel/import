--[[
	Helper function used in tests. This makes it easy to construct hierarchies
	to test out importing in various settings.
]]
local function newFolder(children: { [string]: Instance }): Folder
	local folder = Instance.new("Folder")
	folder.Name = "root"

	for k, v in pairs(children) do
		v.Name = k
		v.Parent = folder
	end

	return folder
end

return newFolder
