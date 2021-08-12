# import("./Module")

This module allows you to write paths for Roblox instances like you do on the filesystem.

Having to constantly type `script.Parent` with varying levels of `.Parent` is tedious and can produce excessively long lines. This module aims to fix this by providing a concise syntax for writing import paths that closely resembles what's used on the filesystem.

## Installation

**Model File (Roblox Studio)**
- Download the `rbxm` model file attached to the latest release from the [GitHub releases page](https://github.com/vocksel/import/releases).
- Insert the model into Studio into a place like `ReplicatedStorage`

**Filesystem**
- Copy the `src` directory into your codebase
- Rename the folder to `import`
- Use a plugin like [Rojo](https://github.com/LPGhatguy/rojo) to sync the files into a place

## Usage

```lua
local import = require(game.ReplicatedStorage.Import)

-- local module = require(script.Module)
local module = import "script/Module"

-- local module = require(script.Parent.Module)
local module = import "./Module"

-- local module = require(script.Parent.Folder.Module)
local module = import "./Folder/Module"

-- local module = require(script.Parent.Parent.Module)
local module = import "../Module"

-- local module = require(script.Parent.Parent.Parent.Module)
local module = import "../../Module"
```

If you only care about a few members of a module, you can import them individually:

```lua
-- local foo = require(script.Parent.Module).foo
local foo = import("./Module", { "foo" })

-- local module = require(script.Parent.Module)
-- local foo = module.foo
-- local bar = module.bar
local foo, bar = import("./Module", { "foo", "bar" })
```

If your dataModel is set to `game` (this is true by default), children of Roblox services can be imported by starting the path with a name of a service:

```lua
-- local module = require(game:GetService("ReplicatedStorage").module)
local module = import "ReplicatedStorage/module"

-- local module = require(game:GetService("ServerStorage").module)
local module = import "ServerStorage/module"
```

Works for any Roblox instance, so you can use this to import assets as well:

```lua
-- local sound = script.Parent:FindFirstChild("Sound")
local sound = import "./Sound"

-- local sound = script.Parent:FindFirstChild("Part")
local part = import "./Part"
```
#### Hot Reloading
If you want to bind a callback to changes in scripts in specific locations (e.g. to reload a Roact tree), you can use the `bindToChangesInLocations` function! All descendants of these locations will be reloaded, and the callback will be fired.
```lua
local locations = {ReplicatedStorage.UIModules}

import.bindToChangesInLocations(locations, function()
	Roact.unmount(oldApp)
	local newApp = Roact.mount(app())
end)
```
_Note: Currently, reloaded modules are parented to `nil`, so script.Parent will not return the expected results._

### Config

You can override the default dataModel of `game` with your own dataModel. This is useful if you're using Import in a library or plugin, or any other case where you don't know the exact path to scripts in your project relative to `game`.

```lua
local pluginOrLibraryRoot = script.Parent
import.setConfig({
	dataModel = pluginOrLibraryRoot
})

-- local coreModule = require(script.Parent.CoreModules.Module)
local coreModule = import "CoreModules/Module"
```

You can set aliases to define starting points for your paths:

```lua
import.setConfig({
	aliases = {
		shared = game.ReplicatedStorage.Shared
	}
})

-- local module = require(game.ReplicatedStorage.Shared.Module)
local module = import "shared/Module"
```

You can also configure the module to use WaitForChild, with a configurable timeout

```lua
import.setConfig({
	useWaitForChild = true
	waitForChildTimeout = 1
})
```

You can configure the alias which you use to represent `script` in your paths.

```lua
import.setConfig({
	currentScriptAlias = "@"
})

-- local module = require(script.Module)
local module = import "@/Module"
```

By default, `import` will throw an error when modulescripts attempt to import eachother in a recursive loop (which would otherwise silently fail). This feature was designed with the assumption the user only has a singular script or localscript as the entry point to the codebase, and you can disable it if the feature causes problems.
```lua
import.setConfig({
	detectRequireLoops = false
})
```

## Development

Install [Rojo](https://github.com/rojo-rbx/rojo/) and then run the following commands:

```sh
$ rojo build -o place.rbxlx
$ rojo serve
```

Open the newly generated place file and start the Rojo plugin.

From here you can modify anything under `src/` and your changes will be synced in.

When you're ready to test, simply press F5 to play.
