----// Date : 2025

-- Requires
local InputService = require(PathtoModule:WaitForChild("InputService"))
local InputConfigs = require(PathToModule:WaitForChild("InputConfigs"))

-- Test
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

-- recommended
InputService.Bind("ONCLICK", InputConfigs.Click)
InputService.Bind("ONPRESSR", InputConfigs.PressR)
