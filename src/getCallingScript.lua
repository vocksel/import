local getInstanceFromFullName = require(script.Parent.getInstanceFromFullName)

local function getCallingScript(): BaseScript?
	local level = 1

	while true do
		local callerName = debug.info(level, "s")

		-- debug.info() will return nil when the level is out of scope of the
		-- traceback, so we can exit out at this point if we didn't find a
		-- calling script.
		--
		-- Fun fact: It might be impossible for this block to run. If
		-- debug.info() returns nil, that means we were not able to find a
		-- calling Script in this loop. But then how else would this function
		-- run if a Script did not call it? Maybe this condition could be
		-- satisfied in CI, but who knows!
		if not callerName then
			return nil
		end

		local caller = getInstanceFromFullName(callerName)

		if caller and caller:IsA("BaseScript") then
			return caller
		end

		level += 1
	end
end

return getCallingScript
