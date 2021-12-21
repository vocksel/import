local t = require(script.Parent.t)
local Llama = require(script.Parent.Llama)
local createImporter = require(script.createImporter)
local Options = require(script.Options)
local getCallingScript = require(script.getCallingScript)

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

local function import(path: string, exports: ({ string })?): Instance?
	local caller = getCallingScript(script)

	local importImpl = createImporter(config.values.root, caller, {
		useWaitForChild = config.values.useWaitForChild,
		waitForChildTimeout = config.values.waitForChildTimeout,
		scriptAlias = config.values.scriptAlias,
		aliases = Llama.Dictionary.join(aliases.values, {
			[config.values.scriptAlias] = caller,
		}),
	})

	return importImpl(path, exports)
end

local api = setmetatable({
	setConfig = config.set,
	setAliases = aliases.set,
	import = import,
}, {
	-- Allows this module to be called as import(), otherwise the user has to write
	-- import.import()
	__call = function(_self, ...)
		return import(...)
	end,
})

return api
