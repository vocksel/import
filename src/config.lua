local join = require(script.Parent.join)

local INVALID_KEY_ERROR = "Failed to set config (%s is not a valid config key)"

local config = {
	values = {
		useWaitForChild = false,
		waitForChildTimeout = 1,
		detectRequireLoops = true,
		currentScriptAlias = "script",
		root = game,
	},
}

function config.setConfig(newConfig)
	for key in pairs(newConfig) do
		print(key, config.values[key])
		if config.values[key] == nil then
			error(INVALID_KEY_ERROR:format(key))
		end
	end

	local newValues = join(config.values, newConfig)

	config.values = newValues

	return newValues
end

function config.getConfig()
	return config.values
end

return config
