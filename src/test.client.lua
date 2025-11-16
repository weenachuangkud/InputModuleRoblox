----// Date : 2025

-- Step 1: requires
local InputService = require(PathtoModule:WaitForChild("InputService"))
local InputConfigs = require(PathToModule:WaitForChild("InputConfigs"))

-- Step 2: setup
InputConfigs.Click.OnInputBegan = function()
  print("Player OnClick Start")
end

InputConfigs.Click.OnInputEnded = function()
  print("Player OnClick Ended")
end

InputConfigs.PressR.OnInputBegan = function()
  print("Player OnPressR Start")
end

InputConfigs.PressR.OnInputEnded = function()
  print("Player OnPressR Ended")
end

-- Step 3: Bind it
--- NOTE: It is recommended to do it manually
InputService.Bind("ONCLICK", InputConfigs.Click)
InputService.Bind("ONPRESSR", InputConfigs.PressR)
