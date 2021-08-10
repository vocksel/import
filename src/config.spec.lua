return function()
	local config = require(script.Parent.config)

	describe("setConfig", function()
		it("should merge the new config with the current", function()
			local values = config.getConfig()
			local newValues = config.setConfig({
				useWaitForChild = true,
			})

			expect(newValues).to.never.equal(values)
			expect(newValues.useWaitForChild).to.equal(true)
			expect(newValues.useWaitForChild).to.never.equal(values.useWaitForChild)
		end)

		it("should throw when trying to set a value that is not in the config", function()
			expect(function()
				config.setConfig({
					foo = true,
				})
			end).to.throw()
		end)
	end)

	describe("getConfig", function()
		it("should return the config object", function()
			local values = config.getConfig()
			expect(values).to.be.a("table")
		end)

		it("should return the config object after updating", function()
			local oldValues = config.getConfig()

			config.setConfig({
				useWaitForChild = true,
			})

			local newValues = config.getConfig()

			expect(oldValues).to.never.equal(newValues)
		end)
	end)
end
