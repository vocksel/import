return function()
	local destructure = require(script.Parent.destructure)

	local object = {
		foo = true,
		bar = false,
	}

	it("should return the destructured members as a tuple", function()
		local foo, bar = destructure(object, { "foo", "bar" })
		expect(foo).to.equal(true)
		expect(bar).to.equal(false)
	end)

	it("should throw when a destructured member does not exist", function()
		expect(function()
			destructure(object, { "undefined" })
		end).to.throw()
	end)
end
