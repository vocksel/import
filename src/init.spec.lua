return function()
	local import = require(script.Parent)

	FOCUS()

	it("should be callable", function()
		expect(type(import)).to.equal("table")

		import("./bind")
		expect(function()
		end).to.never.throw()
	end)
end
