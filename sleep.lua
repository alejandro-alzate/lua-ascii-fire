local socket = require("socket")

---Halts execution based on the given pause
---@param sec number The amount of seconds to halt
local function sleep(sec)
	socket.select(nil, nil, sec)
end

return sleep
