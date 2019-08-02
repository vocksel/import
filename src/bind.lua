--[[
	Binds a method with its object so that it can be used independantly.

	This is useful when exposing a method when you don't also want to attach the
	object to it. For example, when exporting an API.

	Usage:

		locla obj = {
			str = "Example",
			foo = function(self)
				print(self.str)
			end
		}

		local method = bind(obj, obj.foo)

		method() -- "Example"
]]

local function bind(instance, method)
	return function(...)
		return method(instance, ...)
	end
end

return bind
