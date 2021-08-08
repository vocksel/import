local join = require(script.Parent.join)

return function()
	it("should add new values and retain existing ones", function()
		local default = {
			foo = true,
		}

		local extra = {
			bar = false,
		}

		local joined = join(default, extra)

		expect(joined.foo).to.equal(true)
		expect(joined.bar).to.equal(false)
	end)

	it("should override existing values with new ones", function()
		local default = {
			foo = true,
			bar = false,
		}

		local extra = {
			foo = false,
		}

		local joined = join(default, extra)

		expect(joined.foo).to.equal(false)
		expect(joined.bar).to.equal(false)
	end)
end
