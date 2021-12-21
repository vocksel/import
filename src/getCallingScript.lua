local getInstanceFromFullName = require(script.Parent.getInstanceFromFullName)

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

			-- nextCaller can be nil if callerPath is outside the DataModel.
			-- This can happen when an unparented LuaSourceContainer attempts to
			-- import something. In this case, we break out of the loop and call
			-- this function with the useFallback flag enabled.
			nextCaller = getInstanceFromFullName(callerPath)
		end

		if not nextCaller then
			break
		end

		if nextCaller == module then
			foundModule = true
		else
			if foundModule then
				return nextCaller
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
