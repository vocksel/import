local join = require(script.Parent.join)

local Options = {}

function Options.new(defaults, validator)
	local self = {}

	self.values = defaults

	self.set = function(options)
		if validator then
			assert(validator(options))
		end

		local newValues = join(self.values, options)

		self.values = newValues

		return newValues
	end

	return self
end

return Options