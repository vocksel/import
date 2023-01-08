return function()
	local Root = script:FindFirstAncestor("import")

	local getCallingScript = require(script.Parent.getCallingScript)

	local FIXTURE = Root.mocks.callingScriptFallback

	it("returns the LuaSourceContainer that called the function", function()
		local caller = getCallingScript(script)
		expect(caller:IsA("LuaSourceContainer")).to.equal(true)
	end)

	it("works on LuaSourceContainers that are unparented", function()
		local fixture = FIXTURE:Clone()
		expect(require(fixture.module)).to.equal(true)
	end)
end
