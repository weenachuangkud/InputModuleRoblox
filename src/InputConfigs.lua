--[[
	- Author : Mawin CK
	- Date : 11/03/2025
]]

--!strict

type VaildInputs = Enum.UserInputType | Enum.KeyCode

export type InputConfig = {
	Trigger : {VaildInputs} | VaildInputs,
	OnInputBegan : ((InputObject) -> ())?,
	OnInputEnded : ((InputObject) -> ())?,
	MobileButton : (TextButton | ImageButton)?
}

export type InputConfigs = {
	IsMobile : boolean,
	[string] : InputConfig
}

-- NOTE : You can also create InputConfigs separately
local InputConfigs : InputConfigs = {
	IsMobile = false,
  ["Click"] = {
		Trigger = Enum.UserInputType.MouseButton1
	},
  ["PressR"] = {
		Trigger = Enum.KeyCode.R
	}
}

return InputConfigs
