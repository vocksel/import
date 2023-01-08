local Root = script:FindFirstAncestor("import")

local getInstanceFromFullName = require(Root.getInstanceFromFullName)

local function getCallingScript(module: ModuleScript, useFallback: boolean?): LuaSourceContainer
	local level = 1
	local foundModule = false

	useFallback = if useFallback then true else false

	while true do
		local nextCaller: LuaSourceContainer?

		if useFallback then
			nextCaller = getfenv(level).script
		else
			local callerPath = debug.info(level, "s")

			-- This value can be nil if `callerPath` is outside the DataModel.
			-- This can happen when an unparented LuaSourceContainer attempts to
			-- import something, so in this case we break out of the loop and
			-- call getCallingScript() with the useFallback flag down below.
			local instance = getInstanceFromFullName(callerPath)

			if instance:IsA("LuaSourceContainer") then
				nextCaller = instance
			end
		end

		if not nextCaller then
			break
		end

		if nextCaller == module then
			-- Once the module that was passed in has been found, we just need
			-- to loop one more time to find the caller.
			foundModule = true
		else
			if foundModule then
				-- If `foundModule` is true then `nextCaller` is non-nil so we
				-- cast to LuaSourceContainer to clear the nil typing
				return nextCaller :: LuaSourceContainer
			end
		end

		level += 1
	end

	-- If a caller could not be found in the above loop, then this likely means
	-- the caller is unparented. In this case, flip the useFallback flag which
	-- uses getfenv() to get the caller.
	--
	-- This will trigger Luau to disable its optimizations, but this is a rare
	-- edge-case that should not be encountered during normal use so it should
	-- be fine.
	return getCallingScript(module, true)
end

return getCallingScript
