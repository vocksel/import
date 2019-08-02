return function()
	local import = require(script.Parent)

	it("should be callable", function()
		expect(type(import)).to.equal("table")

		expect(function()
			import("./bind")
		end).to.never.throw()
	end)

	it("should not error when calling setConfig", function()
		expect(function()
			import.setConfig({})
		end).to.never.throw()
	end)
end
