return function()
	local Root = script:FindFirstAncestor("import")

	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local newFolder = require(Root.newFolder)
	local getInstanceFromFullName = require(script.Parent.getInstanceFromFullName)

	local folder: Folder

	afterEach(function()
		if folder then
			folder:Destroy()
		end
	end)

	it("should get services", function()
		local path = getInstanceFromFullName("ReplicatedStorage")
		expect(path).to.equal(ReplicatedStorage)
	end)

	it("should work on nested instances", function()
		local module = Instance.new("ModuleScript")

		folder = newFolder({
			foo = newFolder({
				bar = module,
			}),
		})
		folder.Parent = ReplicatedStorage

		local path = getInstanceFromFullName(module:GetFullName())
		expect(path).to.equal(module)
	end)

	it("should work with spec files", function()
		local module = Instance.new("ModuleScript")

		folder = newFolder({
			foo = newFolder({
				["bar.spec"] = module,
			}),
		})
		folder.Parent = ReplicatedStorage

		local path = getInstanceFromFullName(module:GetFullName())
		expect(path).to.equal(module)
	end)

	it("should find spec files BEFORE the module it is associated with", function()
		local module = Instance.new("ModuleScript")

		folder = newFolder({
			foo = newFolder({
				bar = Instance.new("ModuleScript"),
				["bar.spec"] = module,
			}),
		})
		folder.Parent = ReplicatedStorage

		local path = getInstanceFromFullName(module:GetFullName())
		expect(path).to.equal(module)
	end)

	it("should return nil if the first part of the path is not a service", function()
		expect(getInstanceFromFullName("Part")).to.never.be.ok()
	end)
end
