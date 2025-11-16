--[[
	Author : Mawin CK
	Date   : 2025-03-11
	Desc   : Binds InputConfigs to ContextActionService (desktop + mobile)
]]

--!strict

-- Modules
local InputMods = PathTo.Modules:WaitForChild("InputModules")

-- Requires
local InputConfigs = require(InputMods:WaitForChild("InputConfigs"))

-- Connections
local Actives : {[string] : {
	["OnInputBegan"] : RBXScriptConnection?,
	["OnInputEnded"] : RBXScriptConnection?	
}} = {}

local Buttons : {[string] : ImageButton | TextButton} = {}

-- Export Types
export type InputService = {
	Bind : (actionName : string, cfg : InputConfigs.InputConfig) -> (),
	UnBind : (actionName : string) -> (),
	AutoDetectAndBind : () -> (),
	UnBindAll : () -> ()
}

-- Module

local InputService = {}

-- Bind a single named action
function InputService.Bind(
	name: string,
	cfg: InputConfigs.InputConfig
)
	-- Mobile GUI button (optional)
	if cfg.MobileButton and InputConfigs.IsMobile then
		local button : ImageButton | TextButton = cfg.MobileButton
		if not button then warn("No MobileButton for : ", name) return end
		if Actives[name] then warn("Already Bind this actionName") return end
		Actives[name] = {
			OnInputBegan = cfg.OnInputBegan and button.InputBegan:Connect(cfg.OnInputBegan),
			OnInputEnded = cfg.OnInputEnded and button.InputEnded:Connect(cfg.OnInputEnded)
		}
		if not Buttons[name] then Buttons[name] = button end
		if not button.Visible then button.Visible = true end
		return
	end

	-- Desktop / Keyboard / Gamepad binding
	local triggers = cfg.Trigger

	local function handleAction(
		actionName: string,
		inputState: Enum.UserInputState,
		inputObject: InputObject
	): Enum.ContextActionResult
		if inputState == Enum.UserInputState.Begin then
			if cfg.OnInputBegan then
				cfg.OnInputBegan(inputObject)
			end
		elseif inputState == Enum.UserInputState.End then
			if cfg.OnInputEnded then
				cfg.OnInputEnded(inputObject)
			end
		end

		return Enum.ContextActionResult.Sink
	end
	
	if typeof(triggers) == "table" then triggers = table.unpack(triggers) end
	CAS:BindAction(name, handleAction, false, triggers)
end

function InputService.UnBind(Name : string)
	if InputConfigs.IsMobile then
		if Actives[Name] then
			-- My eyes are bleeding seeing these warnings
			if Actives[Name].OnInputBegan then
				Actives[Name].OnInputBegan:Disconnect()
				Actives[Name].OnInputBegan = nil
			end
			if Actives[Name].OnInputEnded then
				Actives[Name].OnInputEnded:Disconnect()
				Actives[Name].OnInputEnded = nil
			end
			local button = Buttons[Name]
			if button then 
				if button.Visible then button.Visible = false end
				Buttons[Name] = nil
			end
		else
			warn(Name .. " Does not exist")
		end
		return
	end
	local isExist = CAS:GetBoundActionInfo(Name)
	if isExist then
		CAS:UnbindAction(Name)
	else
		warn(Name .. " Does not exist")
	end
end

-- Optional: auto-detect mobile & re-bind everything, YOU'RE FUCKING LAZY
function InputService.AutoDetectAndBind()
	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	InputConfigs.IsMobile = isMobile

	for actionName, cfg in pairs(InputConfigs) do
		if typeof(cfg) == "table" and cfg.Trigger then
			InputService.Bind(actionName, cfg)
		end
	end
end

function InputService.UnBindAll()
	if InputConfigs.IsMobile then
		for keyName, active in pairs(Actives) do
			InputService.UnBind(keyName)
		end
		return
	end
	CAS:UnbindAllActions()
end

return InputService
