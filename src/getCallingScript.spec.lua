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
		-- Luau FIXME: Casting to `any` to resolve "TypeError: Unknown require: unsupported path"
		expect((require :: any)(fixture.module)).to.equal(true)
	end)
end
