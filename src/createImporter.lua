local Root = script:FindFirstAncestor("import")

local t = require(Root.Parent.t)
local createPathTraverser = require(Root.createPathTraverser)
local destructure = require(Root.destructure)

type Options = {
	useWaitForChild: boolean?,
	waitForChildTimeout: number?,
	scriptAlias: string?,
	aliases: ({ [string]: Instance })?,
}
local Options = t.strictInterface({
	useWaitForChild = t.optional(t.boolean),
	waitForChildTimeout = t.optional(t.number),
	scriptAlias = t.optional(t.string),
	aliases = t.optional(t.table),
})

local checkOuter = t.tuple(t.Instance, t.Instance, t.optional(Options))
local checkInner = t.tuple(t.string, t.optional(t.array(t.string)))

local function createImporter(root: Instance, start: Instance, options: Options?)
	assert(checkOuter(root, start, options))

	return function(path: string, exports: { string }?): (Instance?, ...Instance?)
		assert(checkInner(path, exports))

		-- This condition is true when the user calls `import("script")`. In
		-- this case, we simply return the `start` instance, which is the script
		-- the import function was called from. Without this, the calling script
		-- gets required if it is a ModuleScript. It does not make sense for a
		-- module to require itself, so instead we return the instance.
		if options and path == options.scriptAlias then
			return start
		end

		-- TODO: Pass in the full `options` table and implement useWaitForChild
		-- and waitForChildTimeout
		local aliases = if options then options.aliases else nil
		local traverse = createPathTraverser(root, start, aliases)
		local instance = traverse(path)

		if instance then
			if instance:IsA("ModuleScript") then
				-- Luau FIXME: Casting to `any` to resolve "TypeError: Unknown
				-- require: unsupported path"
				local source = (require :: any)(instance)

				if exports then
					return destructure(source, exports)
				else
					return source
				end
			else
				return instance
			end
		else
			return nil
		end
	end
end

return createImporter
