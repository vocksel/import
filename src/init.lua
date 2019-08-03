local Importer = require(script.Importer)
local bind = require(script.bind)

local importer = Importer.new()

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
