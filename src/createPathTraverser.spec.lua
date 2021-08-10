return function()
	local createPathTraverser = require(script.Parent.createPathTraverser)

	local function newFolder(children)
		local folder = Instance.new("Folder")
		folder.Name = "root"

		for k, v in pairs(children) do
			v.Name = k
			v.Parent = folder
		end

		return folder
	end

	it("should find instances one level up (script.Parent)", function()
		local start = Instance.new("Script")
		local module = Instance.new("ModuleScript")

		local tree = newFolder({
			module = module,
			start = start,
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("./module")).to.equal(module)
	end)

	it("should find instances two levels up (script.Parent.Parent)", function()
		local start = Instance.new("Script")
		local module = Instance.new("ModuleScript")

		local tree = newFolder({
			module = module,
			folder = newFolder({
				start = start,
			}),
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("../module")).to.equal(module)
	end)

	-- Don't know why you would want to do this, but hey, we support it!
	it("should find instances when using '../' in the middle of a path", function()
		local start = Instance.new("Script")
		local module = Instance.new("ModuleScript")

		local tree = newFolder({
			folder = newFolder({
				module = module,
			}),
			start = start,
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("./folder/../folder/module"))
	end)

	it("should find instances an arbitrary amount of levels up", function()
		local start = Instance.new("Script")
		local module = Instance.new("ModuleScript")

		local tree = newFolder({
			module = module,
			folder = newFolder({
				folder = newFolder({
					start = start,
				}),
			}),
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("../../module")).to.equal(module)
	end)

	it("should find instances using absolute paths", function()
		-- The start does not matter here since we're using absolute paths
		local start = Instance.new("Script")
		local module = Instance.new("ModuleScript")

		local tree = newFolder({
			module = module,
			folder = newFolder({
				start = start,
			}),
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("/module")).to.equal(module)
	end)

	it("should find instances using absolute paths through the DataModel", function()
		-- The start does not matter here since we're using absolute paths
		local start = Instance.new("Script")

		local traverse = createPathTraverser(game, start)

		expect(traverse("/StarterPlayer/StarterPlayerScripts")).to.equal(game.StarterPlayer.StarterPlayerScripts)
	end)

	it("should throw when going past the root", function()
		local start = Instance.new("Script")

		local tree = newFolder({
			start = start,
		})

		local traverse = createPathTraverser(tree, start)

		expect(function()
			traverse("/../nothingOutHere")
		end).to.throw()
	end)

	it("should work for any instance", function()
		local start = Instance.new("Script")

		local tree = newFolder({
			part = Instance.new("Part"),
			sound = Instance.new("Sound"),
			start = start,
		})

		local traverse = createPathTraverser(tree, start)

		expect(traverse("./part")).to.be.ok()
		expect(traverse("./sound")).to.be.ok()
	end)

	it("should support aliases", function()
		local start = Instance.new("Script")

		local tree = newFolder({
			ReplicatedStorage = newFolder({
				sharedModule = Instance.new("ModuleScript"),
			}),
			ServerStorage = newFolder({
				serverModule = Instance.new("ModuleScript"),
			}),
			StarterPlayer = newFolder({
				StarterPlayerScripts = newFolder({
					clientModule = Instance.new("ModuleScript"),
				}),
			}),
		})

		local aliases = {
			server = tree.ServerStorage,
			client = tree.StarterPlayer.StarterPlayerScripts,
			shared = tree.ReplicatedStorage,
		}

		local traverse = createPathTraverser(tree, start, aliases)

		expect(traverse("server/serverModule")).to.be.ok()
		expect(traverse("client/clientModule")).to.be.ok()
		expect(traverse("shared/sharedModule")).to.be.ok()
	end)
end
