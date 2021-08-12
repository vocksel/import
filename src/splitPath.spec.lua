return function()
	local splitPath = require(script.Parent.splitPath)

	it("should return an array of each part of the path", function()
		local root = Instance.new("Folder")

		local parts = splitPath("foo/bar/baz", root)

		expect(#parts).to.equal(3)
		expect(parts[1]).to.equal("foo")
		expect(parts[2]).to.equal("bar")
		expect(parts[3]).to.equal("baz")
	end)

	it("should set the first item to the root if starting with a slash", function()
		local root = Instance.new("Folder")

		local parts = splitPath("/foo", root)

		expect(#parts).to.equal(2)
		expect(parts[1]).to.equal(root)
		expect(parts[2]).to.equal("foo")
	end)
end
