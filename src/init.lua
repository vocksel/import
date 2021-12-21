local t = require(script.Parent.t)
local join = require(script.join)
local createImporter = require(script.createImporter)
local Options = require(script.Options)

local config = Options.new(
	{
		root = game,
		useWaitForChild = false,
		waitForChildTimeout = 1,
		scriptAlias = "script",
	},
	t.strictInterface({
		root = t.optional(t.Instance),
		useWaitForChild = t.optional(t.boolean),
		waitForChildTimeout = t.optional(t.number),
		scriptAlias = t.optional(t.string),
	})
)

local aliases = Options.new({}, t.map(t.string, t.Instance))

local check = t.tuple(t.string, t.optional(t.array(t.string)))

local function importWithCallingScript(caller: BaseScript, path: string, exports: ({ string })?)
	assert(check(path, exports))

	local import = createImporter(config.values.root, caller, {
		useWaitForChild = config.values.useWaitForChild,
		waitForChildTimeout = config.values.waitForChildTimeout,
		scriptAlias = config.values.scriptAlias,
		aliases = join(aliases.values, {
			[config.values.scriptAlias] = caller,
		}),
	})

	return import(path, exports)
end

local api = setmetatable({
	setConfig = config.set,
	setAliases = aliases.set,
	import = function(path: string, exports: ({ string })?)
		local caller = getfenv(2).script
		return importWithCallingScript(caller, path, exports)
	end,
}, {
	-- Allows this module to be called as import(), otherwise the user has to write
	-- import.import()
	__call = function(_, path: string, exports: ({ string })?)
		local caller = getfenv(2).script
		return importWithCallingScript(caller, path, exports)
	end,
})

return api
