local createImporter = require(script.createImporter)
local Options = require(script.Options)

local config = Options.new({
	root = game,
	useWaitForChild = false,
	waitForChildTimeout = 1,
	detectRequireLoops = true,
	scriptAlias = "script",
})

local aliases = Options.new({})

local function importWithCallingScript(path, exports)
	local caller = getfenv(2).script
	local import = createImporter(config.root, caller, {
		waitForChildTimeout = config.waitForChildTimeout,
		detectRequireLoops = config.detectRequireLoops,
		aliases = aliases.get(),
	})

	return import(path, exports)
end

local module = {
	setConfig = config.set,
	setAliases = aliases.set,
	import = importWithCallingScript,
}

-- Allows this module to be called as import(), otherwise the user has to write
-- import.import()
return setmetatable(module, {
	__call = function(_, path, exports)
		importWithCallingScript(path, exports)
	end,
})
