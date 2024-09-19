--ASCII Fire
local asciif = {}
local afastr = ""
local farray = {}
local fchars = " ,;+ltgti!lI?/\\|)(1}{][rcvzjftJUOQocxfChqwWB8&%$#@"

local width = 139
local height = 34

function asciif.emptyArray(w, h, default)
	local array = {}
	for i = 1, w * h do
		array[i] = default
	end
	return array
end

---Clears the state machine
---@return nil
function asciif.load()
	--Clear the [acii fire array string]
	farray = asciif.emptyArray(width, height, 1)
	afastr = ""
end

---Puts fire at the root
---@return nil
function asciif.generateFire()
	do --Only poke the last row
		local from = #farray - width + 1
		local to = #farray
		for _ = from, to do
			local maxCharIndex = fchars:len()
			-- As always zero indexing screws me over, this is the fix:
			--								↓
			local randomCharIndex = math.ceil(math.random() * maxCharIndex)
			local randomCellIndex = math.floor(math.random(from, to))

			farray[randomCellIndex] = randomCharIndex
			--print("Generate:", randomCellIndex, randomCharIndex)
		end
	end
end

---Spreads the fire based on a average matrix
---@return nil
function asciif.expandFire()
	do --Only poke all but the last row
		local from = 1
		local to = #farray - width
		for i = from, to do
			local idx1 = i
			local idx2 = i + 1
			local idx3 = i + width
			local idx4 = i + width + 1

			-- Catching nils because here we ain't doing any JS indexing funny bussiness.
			-- this is the type of nonsense that makes the web somehow tick.

			--Explanation:
			--[[
				The avageValue is calculated from the firePixelsArray elements without throwing an error
				because the JavaScript engine handles array access out of bounds by returning undefined.

				In this context, undefined is treated as NaN (Not-a-Number) during arithmetic operations.
				The loop runs through the array from i = 0 to i < width * (height - 1),
				which is one row less than the total height.

				For each iteration, it accesses:
					firePixelsArray[i]
					firePixelsArray[i + 1]
					firePixelsArray[i + width]
					firePixelsArray[i + width + 1]
				However, there might be cases where i + 1, i + width, or i + width + 1 exceeds the boundaries of the array,
				especially near the edges of the grid. For instance, at the far right of the array (last column),
				i + 1 could exceed the array bounds.

				JavaScript Behavior:
				When you try to access an array element out of bounds, JavaScript returns undefined. In arithmetic
				expressions, undefined is coerced into NaN (Not-a-Number), and any arithmetic operation involving
				NaN results in NaN. However, this is handled gracefully in the code by the subsequent Math.floor() operation.

				Why It Doesn't Break:
				firePixelsArray[i] = Math.floor(averageValue);
				The function Math.floor() can take NaN as input, and it will just return NaN.
				While this isn’t ideal (since it means you might get some incorrect values),
				it won't throw an error and crash the script. If averageValue is NaN, firePixelsArray[i] will be set to NaN.
				However, since NaN doesn’t have a corresponding character in fireChars, you'll end up with undefined or
				potentially some weird behavior in the fire animation.

				How to Avoid This:
				If you want to avoid potential NaN values, you should add bounds checking:

				let sum = 0;
				let count = 0;

				if (firePixelsArray[i] !== undefined) { sum += firePixelsArray[i]; count++; }
				if (firePixelsArray[i + 1] !== undefined) { sum += firePixelsArray[i + 1]; count++;	}
				if (firePixelsArray[i + width] !== undefined) { sum += firePixelsArray[i + width]; count++;	}
				if (firePixelsArray[i + width + 1] !== undefined) { sum += firePixelsArray[i + width + 1]; count++;	}

				let averageValue = sum / count;

				This will ensure that is only averaging valid values, avoiding undefined or NaN in your calculations.

				And that's is the lua workaround of this JS Specific thing.
				Not to dunk on JS but there's a whole github just dedicated to this nonsense:
				https://github.com/denysdovhan/wtfjs
			]]

			-- Starting this at 0.1 makes ever so slightly harder to expand, to get those detached blobs :D
			-- 				↓
			local count = 0.1
			local sum = 0


			if type(farray[idx1]) == "number" then
				sum = sum + farray[idx1]; count = count + 1;
			end
			if type(farray[idx2]) == "number" then
				sum = sum + farray[idx2]; count = count + 1;
			end
			if type(farray[idx3]) == "number" then
				sum = sum + farray[idx3]; count = count + 1;
			end
			if type(farray[idx4]) == "number" then
				sum = sum + farray[idx4]; count = count + 1;
			end

			farray[i] = sum / count
		end
	end
end

---Pokes holes to the root of the fire randomly
---@return nil
function asciif.chokeFire()
	do --Only poke the last row
		local from = #farray - width + 1
		local to = #farray
		for _ = from, to do
			local randomCellIndex = math.floor(math.random(from, to))
			farray[randomCellIndex] = 1
		end
	end
end

---Converts the fire array to a string
---@return nil
function asciif.convertFireArray()
	--Make this a string, breaking it by width in lines
	afastr = ""
	for index, value in pairs(farray) do
		local c = fchars:sub(value, value)
		afastr = afastr .. c
		if index % width == 0 then
			afastr = afastr .. "\n"
		end
	end
end

---Ticks the state machine.
---@return nil
function asciif.update()
	asciif.generateFire()

	--Chocking fire twice so it get more chances to the gaps
	asciif.chokeFire()
	asciif.chokeFire()


	asciif.expandFire()
	asciif.convertFireArray()
end

---Gets the processed string of the fire.
---@return string
function asciif.getBuffer()
	return afastr
end

asciif.__tostring = asciif.getBuffer()

---Sets the width of the text buffer to `w`
---@generic Number: number
---@param w Number
---@return nil
function asciif.setWidth(w)
	if type(w) ~= "number" or type(w) ~= "nil" then
		error("setWidth expects a number not " .. type(w))
	end
	width = w
end

---Sets the width of the text buffer to `h`
---@generic Number: number
---@param h Number
---@return nil
function asciif.setHeigth(h)
	if type(h) ~= "number" or type(h) ~= "nil" then
		error("setWidth expects a number not " .. type(h))
	end
	height = h
end

asciif.load()

return asciif
