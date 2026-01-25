--[[
	Author : Mawin CK
	Date   : 2025-03-11
	Desc   : Binds InputConfigs to ContextActionService (desktop + mobile)
]]

-- Service
local CAS = game:GetService("ContextActionService")

-- Modules
local InputMods = PathTo:WaitForChild("InputModules")

-- Requires
local InputTypes = require(InputMods:WaitForChild("InputTypes"))


-- Connections
local Actives : {[string] : {
	["OnInputBegan"] : RBXScriptConnection?,
	["OnInputEnded"] : RBXScriptConnection?	
}} = {}

local Buttons : {[string] : ImageButton | TextButton} = {}

-- Export Types
export type InputService = {
	Bind : (actionName : string, cfg : InputTypes.InputConfig) -> (),
	UnBind : (actionName : string) -> (),
	UnBindByName : (actionName : string) -> (),
	UnBindAll : () -> ()
}

-- Module

local InputService = {}

-- Bind a single named action
function InputService.Bind(
	name: string,
	cfg: InputTypes.InputConfig
)
	assert(cfg, "InputConfig is nil")
	-- Mobile GUI button (optional)
	if cfg.MobileButton and cfg.IsMobile then
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

		return cfg.Sink and Enum.ContextActionResult.Sink or Enum.ContextActionResult.Pass
	end

	if typeof(triggers) == "table" then 
		triggers = table.unpack(triggers)
	end
	CAS:BindAction(name, handleAction, false, triggers)
end

function InputService.UnBind(Name : string, IsMobile : boolean)
	if IsMobile then
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

function InputService.IsBinded(Name : string, IsMobile: boolean?) : boolean
	if IsMobile then
		return Buttons[Name] ~= nil
	end
	return Actives[Name] ~= nil
end


function InputService.UnBindAll()
	for keyName, active in Buttons do
		InputService.UnBind(keyName)
	end
	CAS:UnbindAllActions()
end

return InputService
