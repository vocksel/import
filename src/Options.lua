local join = require(script.Parent.join)

local INVALID_KEY_ERROR = "failed to set '%s = %s' (%s is not a valid key, must be one of: %s)"

local Options = {}

function Options.new(defaults)
	local self = {}
	self.values = defaults

	self._validate = function(options)
		for key, value in pairs(options) do
			if self.values[key] == nil then
				-- Pack up the possible keys into a string so the user knows
				-- what options are available.
				local validKeys = {}
				for defaultKey in self.values do
					table.insert(validKeys, defaultKey)
				end
				validKeys = table.concat(validKeys, ", ")

				error(INVALID_KEY_ERROR:format(key, value, key, validKeys))
			end
		end
	end

	self.get = function()
		return self.values
	end

	self.set = function(options)
		self._validate(options)
		local newValues = join(self.values, options)
		self.values = newValues
		return newValues
	end

	return self
end

return Options
