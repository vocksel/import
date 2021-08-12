return function()
	local Options = require(script.Parent.Options)
	local t = require(script.Parent.t)

	describe("get", function()
		it("should return the options object", function()
			local options = Options.new({
				foo = false,
			})

			local values = options.values

			expect(values).to.be.a("table")
			expect(values.foo).to.equal(false)
		end)

		it("should return the new options object after updating", function()
			local options = Options.new({
				foo = false,
			})

			local oldValues = options.values

			options.set({
				foo = true,
			})

			local newValues = options.values

			expect(oldValues).to.never.equal(newValues)
		end)
	end)

	describe("set", function()
		it("should merge the new options with the old", function()
			local options = Options.new({
				foo = false,
			})

			local oldValues = options.values
			local newValues = options.set({
				foo = true,
			})

			expect(newValues).to.never.equal(oldValues)
			expect(newValues.foo).to.equal(true)
			expect(newValues.foo).to.never.equal(oldValues.foo)
		end)

		it("should throw when trying to set a value that is not in the config", function()
			local options = Options.new(
				{
					foo = false,
				},
				t.strictInterface({
					foo = t.boolean,
				})
			)

			expect(function()
				options.set({
					bar = true,
				})
			end).to.throw()
		end)
	end)
end
