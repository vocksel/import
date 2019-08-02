return function()
	local import = require(script.Parent)

	it("should be callable", function()
		expect(type(import)).to.equal("table")

		expect(function()
			import("./bind")
		end).to.never.throw()
	end)
end
