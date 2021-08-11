local splitPath = require(script.Parent.splitPath)

local COULD_NOT_RESOLVE_PATH = "'%s' is not the name of a service, alias, or child of current dataModel"
local COULD_NOT_FIND_CHILD = "could not resolve a child %q in %q"

local function createPathTraverser(root: Instance, start: Instance, aliases: table)
	-- This is used to ensure `../` will move upwards to script.Parent.Parent,
	-- but `../../` will only move up one parent after that.
	local hasAscended = false

	aliases = aliases or {}

	return function(path)
		if path == "/" then
			return root
		end

		local current = start
		local parts = splitPath(path, root)

		for index, pathPart in pairs(parts) do
			local nextInstance

			-- The first part of the path has some special handling. This is
			-- where we look for aliases, or whether the path is relative or
			-- absolute.
			if index == 1 then
				local alias = aliases[pathPart]

				if pathPart == root then
					current = root
					continue
				elseif pathPart == "." then
					nextInstance = current.Parent
				elseif alias then
					nextInstance = alias
				end
			end

			if pathPart == ".." then
				if hasAscended or index > 1 then
					nextInstance = current.Parent
				else
					nextInstance = current.Parent.Parent
					hasAscended = true
				end
			end

			if not nextInstance then
				nextInstance = current:FindFirstChild(pathPart)
				assert(nextInstance, COULD_NOT_FIND_CHILD:format(pathPart, path))
			end

			current = nextInstance
		end

		assert(current, COULD_NOT_RESOLVE_PATH:format(path))

		return current
	end
end

return createPathTraverser
