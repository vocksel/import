local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.TestEz)

local root = ReplicatedStorage.import
TestEZ.TestBootstrap:run({ root })
