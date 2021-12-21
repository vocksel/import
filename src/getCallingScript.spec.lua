return function()
	local ServerScriptService = game:GetService("ServerScriptService")

	local getCallingScript = require(script.Parent.getCallingScript)

	local TEST_RUNNER = ServerScriptService.tests

	it("returns the Script instance that called the function", function()
		local caller = getCallingScript()
		expect(caller).to.equal(TEST_RUNNER)
	end)
end
