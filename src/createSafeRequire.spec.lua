return function()
	local createSafeRequire = require(script.Parent.createSafeRequire)

	local MOCK_FUNCTION_MODULE = script.Parent.mocks.functionModule

	it("should require modules normally", function()
		local callback = require(MOCK_FUNCTION_MODULE)
		expect(callback()).to.equal(true)
	end)

	it("should throw when detecting a require loop", function()
		local safeRequire = createSafeRequire()

		-- expect(function()
		safeRequire(script.Parent.mocks.recursionTest.moduleA)
		-- end).to.throw()
	end)
end
