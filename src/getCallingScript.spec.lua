return function()
	local getCallingScript = require(script.Parent.getCallingScript)

	it("returns the LuaSourceContainer that called the function", function()
		local caller = getCallingScript(script)
		expect(caller:IsA("LuaSourceContainer")).to.equal(true)
	end)
end
