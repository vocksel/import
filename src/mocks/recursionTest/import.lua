local Importer = require(script.Parent.Parent.Parent.Importer)
local bind = require(script.Parent.Parent.Parent.bind)

local importer = Importer.new(script.Parent)

local module = {
	setConfig = bind(importer, importer.setConfig),
}

-- Allows this module to be called as import(), otherwise we'd be writing import.import()
return setmetatable(module, {
	__call = function(_, path, exports)
		local caller = getfenv(2).script
		return importer:import(caller, path, exports)
	end
})
