# InputModuleRoblox

A lightweight `ContextActionService` wrapper for Roblox that unifies desktop keyboard/mouse, gamepad, and mobile touch input behind a single API.

## Features

- **One API for all platforms** — define input once, works on PC and mobile
- **Two mobile modes** — use your own GUI buttons or let CAS auto-create touch buttons
- **Config-driven** — declarative `InputConfig` tables keep bindings readable

## Installation

1. Place `InputService.luau` and `InputTypes.luau` in a shared module folder (e.g. `ReplicatedStorage/Input`)
2. In any `Script` or `LocalScript`:

```lua
local InputService = require(path.to.InputService)
```

## API

### `InputService.Bind(name, config, isMobile?)`

Binds a named action. Platform is auto-detected via `UserInputService.TouchEnabled` unless overridden.

| Param | Type | Description |
|---|---|---|
| `name` | `string` | Unique action identifier |
| `config` | `InputConfig` | Trigger, callbacks, and mobile options |
| `isMobile?` | `boolean?` | Force mobile mode override |

### `InputService.UnBind(name)`

Unbinds a single action and cleans up all connections.

### `InputService.UnBindAll()`

Unbinds all tracked actions and calls `CAS:UnbindAllActions()`.

### `InputService.IsBinded(name)`

Returns `true` if the action is currently bound (checks both custom button and CAS bindings).

## InputConfig

Defined in `InputTypes.luau`:

```lua
type InputConfig = {
    Trigger: {Enum.UserInputType | Enum.KeyCode}
          | (Enum.UserInputType | Enum.KeyCode),
    OnInputBegan: ((InputObject) -> ())?,
    OnInputEnded: ((InputObject) -> ())?,
    MobileButton: (TextButton | ImageButton)?,
    Sink: boolean?,
}
```

| Field | Description |
|---|---|
| `Trigger` | A single key/input type or an array of them that activate this action |
| `OnInputBegan` | Fires when the input starts |
| `OnInputEnded` | Fires when the input ends |
| `MobileButton` | **Optional.** A `TextButton` or `ImageButton` reference for custom UI on any platform |
| `Sink` | If `true`, consumes the input so it doesn't propagate |

## Mobile Modes

The module has two mobile paths — **custom UI** and **auto-created** — determined by whether `MobileButton` is set:

### Custom UI button (any platform)

When you pass a `MobileButton` reference, the module connects directly to the button's `InputBegan`/`InputEnded` events. Works the same on PC and mobile.

```lua
local myButton = script.Parent.JumpButton -- GuiButton

InputService.Bind("Jump", {
    Trigger = Enum.KeyCode.Space,
    MobileButton = myButton,
    OnInputBegan = function()
        -- handle jump
    end,
})
```

### Auto-created touch button (mobile only)

When `MobileButton` is nil and the device is mobile, `ContextActionService:BindAction()` is called with `createTouchButton = true`, which spawns a built-in on-screen button automatically. No GUI work needed.

```lua
InputService.Bind("Reload", {
    Trigger = Enum.KeyCode.R,
    OnInputBegan = function()
        -- handle reload
    end,
})
```

On desktop the same config binds to the `R` key instead.

## Examples

### Desktop only

```lua
InputService.Bind("Shoot", {
    Trigger = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 },
    OnInputBegan = function()
        weapon:StartFiring()
    end,
    OnInputEnded = function()
        weapon:StopFiring()
    end,
    Sink = true,
})
```

### Mobile with custom button

```lua
InputService.Bind("Interact", {
    Trigger = Enum.KeyCode.E,
    MobileButton = script.Parent.InteractButton,
    OnInputBegan = function()
        proximityPrompt:Trigger()
    end,
})
```

### Unbind when leaving a state

```lua
InputService.UnBind("Shoot")
InputService.UnBindAll()
```

## License

MIT © 2025 Mawin Chuangkud
