local asciif = require("asciif")
local sleep = require("sleep")

while true do
	--Clean screen so some terminals can cope with it
	io.stdout:write("\027[2J")
	asciif.update()
	print(asciif.getBuffer())
	sleep(0.04)
end
