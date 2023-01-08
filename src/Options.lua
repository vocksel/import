local Root = script:FindFirstAncestor("import")

local Llama = require(Root.Parent.Llama)

local Options = {}

type Validator = (value: any) -> (boolean, string?)

function Options.new(defaults: { [string]: any }, validator: Validator?)
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
