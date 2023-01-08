local COULD_NOT_RESOLVE_PATH = "'%s' is not the name of a service, alias, or child of current dataModel"
local COULD_NOT_FIND_CHILD = "could not resolve a child %q in %q"

local function createPathTraverser(root: Instance, start: Instance, aliases: { [string]: Instance }?)
	-- This is used to ensure `../` will move upwards to script.Parent.Parent,
	-- but `../../` will only move up one parent after that.
	local hasAscended = false

	return function(path)
		if path == "/" then
			return root
		end

		local current = start
		local parts = path:split("/")

		for index, pathPart in pairs(parts) do
			local nextInstance: Instance?

			-- The first part of the path has some special handling. This is
			-- where we look for aliases, or whether the path is relative or
			-- absolute.
			if index == 1 then
				local alias: Instance
				if aliases then
					alias = aliases[pathPart]
				end

				-- An empty string at the start of the path means we're dealing with
				-- an absolute path (like `/foo/bar`. In this case, we use the
				-- `root` argument and traverse from there)
				if pathPart == "" then
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
					local parent = current.Parent
					if parent then
						nextInstance = parent.Parent
					end
					hasAscended = true
				end
			end

			if nextInstance then
				current = nextInstance
			else
				nextInstance = current:FindFirstChild(pathPart)
				assert(nextInstance, COULD_NOT_FIND_CHILD:format(pathPart, path))
				current = nextInstance
			end
		end

		assert(current, COULD_NOT_RESOLVE_PATH:format(path))

		return current
	end
end

return createPathTraverser
