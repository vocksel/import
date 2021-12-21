local getInstanceFromFullName = require(script.Parent.getInstanceFromFullName)

local function getCallingScript(module: ModuleScript): LuaSourceContainer
	local level = 1
	local foundModule = false

	while true do
		local callerPath = debug.info(level, "s")
		local nextCaller = getInstanceFromFullName(callerPath)

		if nextCaller == module then
			foundModule = true
		else
			if foundModule then
				return nextCaller
			end
		end

		level += 1
	end
end

return getCallingScript
