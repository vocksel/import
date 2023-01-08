return function()
	local Root = script:FindFirstAncestor("import")

	local newFolder = require(Root.newFolder)
	local createImporter = require(script.Parent.createImporter)

	local MOCK_MODULE = Root.mocks.tableModule

	it("should error for invalid argument types", function()
		expect(function()
			(createImporter :: any)("bad", Instance.new("Folder"))
		end).to.throw()

		expect(function()
			(createImporter :: any)(Instance.new("Folder"), "bad")
		end).to.throw()

		expect(function()
			(createImporter :: any)()
		end).to.throw()
	end)

	it("should error when given an invalid option", function()
		expect(function()
			createImporter(Instance.new("Folder"), Instance.new("Folder"), {
				badOption = true,
			})
		end).to.throw()
	end)

	it("should support custom aliases", function()
		local start = Instance.new("Script")
		local child = Instance.new("Folder")

		local tree = newFolder({
			nest1 = newFolder({
				nest2 = newFolder({
					alias = newFolder({
						child = child,
					}),
				}),
			}),
			start = start,
		})

		local aliases = {
			alias = tree.nest1.nest2.alias,
		}

		local import = createImporter(tree, start, {
			aliases = aliases,
		})

		expect(import("alias/child")).to.equal(child)
	end)

	it("should allow the use of WaitForChild", function()
		-- TODO: Implement an option to enable WaitForChild
	end)

	it("should throw when deteching a require loop", function()
		-- TODO: Add in require loop detection
	end)

	it("should support destructuring members from a module", function()
		local start = Instance.new("Script")

		local tree = newFolder({
			start = start,
			module = MOCK_MODULE:Clone(),
		})

		local import = createImporter(tree, start)

		local foo, bar = import("./module", { "foo", "bar" })

		expect(foo).to.equal("foo")
		expect(bar).to.equal("bar")
	end)

	it("should error when attempting to destructure a member that does not exist", function()
		local start = Instance.new("Script")

		local tree = newFolder({
			start = start,
			module = MOCK_MODULE:Clone(),
		})

		local import = createImporter(tree, start)

		expect(function()
			import("./module", { "undefined" })
		end).to.throw()
	end)
end
