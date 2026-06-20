----// Date : 2025

-- Step 1: requires
local InputService = require(script.Parent:WaitForChild("InputModule"))

-- Step 2: define configs
local Click = {
	Trigger = Enum.UserInputType.MouseButton1,
	OnInputBegan = function()
		print("Player OnClick Start")
	end,
	OnInputEnded = function()
		print("Player OnClick Ended")
	end,
}

local PressR = {
	Trigger = Enum.KeyCode.R,
	OnInputBegan = function()
		print("Player OnPressR Start")
	end,
	OnInputEnded = function()
		print("Player OnPressR Ended")
	end,
}

-- Step 3: Bind it
InputService.Bind("ONCLICK", Click)
InputService.Bind("ONPRESSR", PressR)
