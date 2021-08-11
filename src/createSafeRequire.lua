local REQUIRE_LOOP_ERROR = "require loop detected when attempting to import %q"

local function createSafeRequire()
	local pending = {}

	return function(module: ModuleScript)
		local isPending = pending[module]

		-- If a require for a module hasn't completed when another module tries to
		-- require it, we know that it's attempting to require modules in a loop.
		if isPending then
			pending[module] = nil
			error(REQUIRE_LOOP_ERROR:format(module:GetFullName()))
		else
			pending[module] = true
		end

		-- Because requiring a module runs all the code in the module first before
		-- returning, any import calls that module makes will run before require
		-- actually returns. Because of this, by adding the module to the list of
		-- requiring modules, we can build out a chain of dependencies. Once the
		-- deepest modules are required, the recursion completes, and all the
		-- modules return their values, at which point we remove them from the
		-- currently requiring table.
		local result = require(module)

		pending[module] = nil
		return result
	end
end

return createSafeRequire
