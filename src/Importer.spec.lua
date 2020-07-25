return function()
	local Importer = require(script.Parent.Importer)

	local MOCK_TABLE_MODULE = script.Parent.mocks.tableModule
	local MOCK_FUNCTION_MODULE = script.Parent.mocks.functionModule

	-- Used for constructing fake DataModels
	local function newFolder(children)
		local folder = Instance.new("Folder")
		folder.Name = "game"

		if children then
			for name, child in pairs(children) do
				child.Name = name
				child.Parent = folder
			end
		end

		return folder
	end

	describe("setConfig", function()
		it("should allow you to change internal values", function()
			local importer = Importer.new()
			local aliases =  { foo = Instance.new("Part") }

			importer:setConfig({
				aliases = aliases
			})

			expect(importer._config.aliases).to.equal(aliases)
		end)

		it("should not mutate the old config", function()
			local importer = Importer.new()
			local oldConfig = importer._config

			importer:setConfig({
				aliases = { foo = Instance.new("Part") },
				useWaitForChild = true,
				waitForChildTimeout = 1,
				detectRequireLoops = false,
				currentScriptAlias = "asjdhasdj",
			})

			expect(importer._config).to.never.equal(oldConfig)
		end)

		it("should error when given a key it doesn't recognize", function()
			local importer = Importer.new()

			expect(function()
				importer:setConfig({
					thisWillNeverExistAndIfItDoesWeHaveBiggerProblems = true
				})
			end).to.throw()
		end)
	end)

	describe("import", function()
		it("shouldn't break if using waitForChild", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				Module = mockModule,
				Script = mockScript,
			})

			local importer = Importer.new(mockDataModel)

			importer:setConfig({
				useWaitForChild = true,
				waitForChildTimeout = 1
			})

			-- local module = require(script.Parent.Module)
			local module = importer:import(mockScript, "./Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should import a module from the same level (script.Parent)", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				Module = mockModule,
				Script = mockScript,
			})

			local importer = Importer.new(mockDataModel)

			-- local module = require(script.Parent.Module)
			local module = importer:import(mockScript, "./Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("it should import a module from one level above (script.Parent.Parent)", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				Module = mockModule,
				ServerScriptService = newFolder({
					Script = mockScript,
				})
			})

			local importer = Importer.new(mockDataModel)

			 -- local module = require(script.Parent.Parent.foo)
			local module = importer:import(mockScript, "../Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should import a module from two levels above (script.Parent.Parent.Parent)", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				Module = mockModule,
				ReplicatedStorage = newFolder({
					Nesting = newFolder({
						Script = mockScript,
					})
				})
			})

			local importer = Importer.new(mockDataModel)

			 -- local module = require(script.Parent.Parent.Parent.Module)
			local module = importer:import(mockScript, "../../Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should import a module from a sibling one level down (script.Parent.ReplicatedStorage:FindFirstChild())", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				Script = mockScript,
				ReplicatedStorage = newFolder({
					Module = mockModule,
				})
			})

			local importer = Importer.new(mockDataModel)

			local module = importer:import(mockScript, "./ReplicatedStorage/Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should import children of the current script (script:FindFirstChild)", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local part = Instance.new("Part", mockScript)

			local mockDataModel = newFolder({
				ServerScriptService = newFolder({
					Script = mockScript,
				}),
				ReplicatedStorage = newFolder({
					Module = mockModule,
				})
			})

			local importer = Importer.new(mockDataModel)

			-- local module = require(game.ReplicatedStorage.Module)
			local instance = importer:import(mockScript, "script/Part")

			expect(instance).to.equal(part)
		end)

		it("should have support for paths relative to the DataModel", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				ServerScriptService = newFolder({
					Script = mockScript,
				}),
				ReplicatedStorage = newFolder({
					Module = mockModule,
				})
			})

			local importer = Importer.new(mockDataModel)

			-- local module = require(game.ReplicatedStorage.Module)
			local module = importer:import(mockScript, "ReplicatedStorage/Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should have support for aliases", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local mockDataModel = newFolder({
				ServerScriptService = newFolder({
					Script = mockScript,
				}),
				ReplicatedStorage = newFolder({
					Module = mockModule,
				})
			})

			local importer = Importer.new(mockDataModel)

			importer:setConfig({
				aliases = {
					alias = mockDataModel.ReplicatedStorage
				}
			})

			-- local module = require(path.to.alias.Module)
			local module = importer:import(mockScript, "alias/Module")

			expect(type(module)).to.equal("table")
			expect(module.foo).to.equal("foo")
		end)

		it("should support changing the current script alias", function()
			local mockScript = Instance.new("Script")
			local mockModule = MOCK_TABLE_MODULE:Clone()

			local part = Instance.new("Part", mockScript)

			local mockDataModel = newFolder({
				ServerScriptService = newFolder({
					Script = mockScript,
				}),
				ReplicatedStorage = newFolder({
					Module = mockModule,
				})
			})

			local importer = Importer.new(mockDataModel)

			importer:setConfig({
				aliases = {
					alias = mockDataModel.ReplicatedStorage
				},
				currentScriptAlias = "@"
			})

			-- local module = require(path.to.alias.Module)
			local part = importer:import(mockScript, "@/Part")

			expect(part).to.equal(part)
		end)

		it("should detect require loops and error", function()
			local import = require(script.Parent)

			expect(function()
				local module = import "./recursionTest/recursiveModule"
			end).to.throw()
		end)

		describe("roblox services", function()
			it("should have support for Roblox services", function()
				local mockScript = Instance.new("Script")
				local importer = Importer.new()

				expect(importer:import(mockScript, "ReplicatedStorage")).to.equal(game.ReplicatedStorage)
				expect(importer:import(mockScript, "ServerScriptService")).to.equal(game.ServerScriptService)
				expect(importer:import(mockScript, "ServerStorage")).to.equal(game.ServerStorage)
			end)

			it("should import instances inside services", function()
				-- Since we can't mock a service, we just have to be careful and
				-- clear up afterwards.

				local ReplicatedStorage = game:GetService("ReplicatedStorage")

				local mockScript = Instance.new("Script")
				local mockModule = MOCK_TABLE_MODULE:Clone()
				mockModule.Name = "Module"
				mockModule.Parent = ReplicatedStorage

				local importer = Importer.new()

				local module = importer:import(mockScript, "ReplicatedStorage/Module")

				expect(type(module)).to.equal("table")
				expect(module.foo).to.equal("foo")

				-- Clean up, otherwise we'll be fill up ReplicatedStorage with
				-- garbage over time.
				mockModule:Destroy()
			end)
		end)

		describe("importing individual exports", function()
			it("should allow you to import indiviudal variables from a module", function()
				local mockScript = Instance.new("Script")
				local mockModule = MOCK_TABLE_MODULE:Clone()

				local mockDataModel = newFolder({
					Script = mockScript,
					Module = mockModule,
				})

				local importer = Importer.new(mockDataModel)

				-- local foo = require(script.Parent.Module).foo
				local foo = importer:import(mockScript, "./Module", { "foo" })

				expect(foo).to.equal("foo")
			end)

			it("should allow you to import multiple exports", function()
				local mockScript = Instance.new("Script")
				local mockModule = MOCK_TABLE_MODULE:Clone()

				local mockDataModel = newFolder({
					Script = mockScript,
					Module = mockModule,
				})

				local importer = Importer.new(mockDataModel)

				-- local foo = require(script.Parent.foo)
				-- local foo = foo.foo
				-- local bar = foo.bar
				local foo, bar = importer:import(mockScript, "./Module", { "foo", "bar" })

				expect(foo).to.equal("foo")
				expect(bar).to.equal("bar")
			end)

			it("should error when attempting to get an export that doesn't exist", function()
				local mockScript = Instance.new("Script")
				local mockModule = MOCK_TABLE_MODULE:Clone()

				local mockDataModel = newFolder({
					Script = mockScript,
					Module = mockModule,
				})

				local importer = Importer.new(mockDataModel)

				expect(function()
					importer:import(mockScript, "./Module", { "doesNotExist" })
				end).to.throw()
			end)

			it("should error when the module is not a table", function()
				local mockScript = Instance.new("Script")
				local mockModule = MOCK_FUNCTION_MODULE:Clone()

				local mockDataModel = newFolder({
					Script = mockScript,
					Module = mockModule,
				})

				local importer = Importer.new(mockDataModel)

				expect(function()
					importer:import(mockModule, "./Module", { "foo" })
				end).to.throw()
			end)
		end)

		it("should support importing any other instance", function()
			local mockScript = Instance.new("Script")

			local mockDataModel = newFolder({
				Script = mockScript,
				Sound = Instance.new("Sound"),
			})

			local importer = Importer.new(mockDataModel)
			local animation = importer:import(mockScript, "./Sound")

			expect(animation:IsA("Sound")).to.be.ok()
		end)

		it("should error at the first part of the path that doesn't exist", function()
			local mockScript = Instance.new("Script")

			local mockDataModel = newFolder({
				Script = mockScript,
			})

			local importer = Importer.new(mockDataModel)

			expect(function()
				importer:import(mockScript, "./thisDoesntExist")
			end).to.throw()
		end)
	end)
end
