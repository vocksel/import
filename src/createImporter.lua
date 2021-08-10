local createPathTraverser = require(script.Parent.createPathTraverser)
local destructure = require(script.Parent.destructure)

local function createImporter(root, start, aliases)
	return function(path, exports)
		local traverse = createPathTraverser(root, start, aliases)
		local instance = traverse(path)

		if instance then
			if instance:IsA("ModuleScript") then
				local source = require(instance)

				if exports then
					return destructure(source, exports)
				else
					return source
				end
			else
				return instance
			end
		end
	end
end

return createImporter
