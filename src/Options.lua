local Llama = require(script.Parent.Parent.Llama)

local Options = {}

function Options.new(defaults: { [string]: any }, validator: (any) -> boolean)
	local self = {}

	self.values = defaults

	self.set = function(options)
		if validator then
			assert(validator(options))
		end

		local newValues = Llama.Dictionary.join(self.values, options)

		self.values = newValues

		return newValues
	end

	return self
end

return Options
