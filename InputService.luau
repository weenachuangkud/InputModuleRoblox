--[[
	Author : Mawin CK
	Date   : 2025-03-11
	Desc   : Binds InputConfigs to ContextActionService (desktop + mobile)
]]

-- Services
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

-- Types
type VaildInputs = Enum.UserInputType | Enum.KeyCode

export type InputConfig = {
	Trigger : {VaildInputs} | VaildInputs,
	OnInputBegan : ((InputObject) -> ())?,
	OnInputEnded : ((InputObject) -> ())?,
	MobileButton : (TextButton | ImageButton)?,
	Sink : boolean?,
}

export type InputService = {
	Bind : (actionName : string, cfg : InputConfig, IsMobile : boolean?) -> (),
	UnBind : (actionName : string) -> (),
	UnBindAll : () -> (),
	IsBinded : (actionName : string) -> boolean
}

-- State
local Actives : {[string] : {
	OnInputBegan : RBXScriptConnection?,
	OnInputEnded : RBXScriptConnection?,
	HasButton : boolean?
}} = {}

-- Module

local InputService = {}

function InputService.Bind(name : string, cfg : InputConfig, IsMobile : boolean?)
	assert(cfg, "InputConfig is nil")
	if IsMobile == nil then
		IsMobile = UIS.TouchEnabled
	end

	if Actives[name] then
		warn("Already bound action: ", name)
		return
	end

	-- Custom UI button (any platform)
	if cfg.MobileButton then
		local button : ImageButton | TextButton = cfg.MobileButton
		Actives[name] = {
			OnInputBegan = cfg.OnInputBegan and button.InputBegan:Connect(cfg.OnInputBegan),
			OnInputEnded = cfg.OnInputEnded and button.InputEnded:Connect(cfg.OnInputEnded),
			HasButton = true
		}
		return
	end

	-- CAS binding (desktop key/mouse, or auto-created touch button on mobile)
	local createTouchButton = IsMobile
	local triggers = cfg.Trigger

	local function handleAction(
		actionName : string,
		inputState : Enum.UserInputState,
		inputObject : InputObject
	) : Enum.ContextActionResult
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
	CAS:BindAction(name, handleAction, createTouchButton, triggers)

	Actives[name] = { HasButton = false }
end

function InputService.UnBind(name : string)
	local active = Actives[name]
	if not active then
		warn(name .. " is not bound")
		return
	end

	if active.HasButton then
		if active.OnInputBegan then
			active.OnInputBegan:Disconnect()
		end
		if active.OnInputEnded then
			active.OnInputEnded:Disconnect()
		end
	else
		if CAS:GetBoundActionInfo(name) then
			CAS:UnbindAction(name)
		end
	end

	Actives[name] = nil
end

function InputService.IsBinded(name : string)
	if Actives[name] then
		return true
	end
	return CAS:GetBoundActionInfo(name) ~= nil
end

function InputService.UnBindAll()
	local names = {}
	for name in Actives do
		table.insert(names, name)
	end
	for _, name in names do
		InputService.UnBind(name)
	end
	CAS:UnbindAllActions()
end

return InputService
