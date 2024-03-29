return function()
	local ServerStorage = game:GetService("ServerStorage")

	local import = require(script.Parent)

	describe("import", function()
		it("should import relative to this script", function()
			local tableModule = import.import("./mocks/tableModule")
			expect(tableModule).to.be.ok()
		end)

		it("should run when calling the module", function()
			local tableModule = import("./mocks/tableModule")
			expect(tableModule).to.be.ok()
		end)

		it("should add a `script` alias", function()
			expect(import("script")).to.equal(script)
		end)
	end)

	describe("setConfig", function()
		it("should update the config", function()
			expect(import("/")).to.equal(game)

			import.setConfig({
				root = game.ReplicatedStorage,
			})

			expect(import("/")).to.equal(game.ReplicatedStorage)

			-- Reset so other tests are uneffected
			import.setConfig({
				root = game,
			})
		end)

		it("should be able to change the script alias name", function()
			expect(import("script")).to.equal(script)

			import.setConfig({
				scriptAlias = "@",
			})

			expect(import("@")).to.equal(script)

			-- Reset so other tests are uneffected
			import.setConfig({
				scriptAlias = "script",
			})
		end)
	end)

	describe("setAliases", function()
		it("should add aliases for import() to use", function()
			import.setAliases({
				server = ServerStorage,
			})

			expect(import("server")).to.equal(ServerStorage)

			-- Reset so other tests are uneffected
			import.setAliases({})
		end)

		it("should not be able to override the `script` alias", function()
			local newScript = Instance.new("Script")

			import.setAliases({
				["script"] = newScript,
			})

			expect(import("script")).to.never.equal(newScript)
			expect(import("script")).to.equal(script)

			-- Reset so other tests are uneffected
			import.setAliases({})
		end)
	end)
end
