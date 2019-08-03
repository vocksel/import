# import()

This module allows you to write paths for Roblox instances like you do on the filesystem.

Having to constantly type `script.Parent` with varying levels of `.Parent` is tedious and leads to lengthy lines. Getting individual members of a module is also troublesome, as you have to assign each one to a variable after requiring.

This module aims to fix that by providing a concise syntax for writing import paths that closely resembles what's used on the filesystem, as well as taking inspiration from the `import { foo } from "module"` syntax from JavaScript.

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

-- local module = require(script.Parent.Module)
local module = import("./Module")

-- local module = require(script.Parent.Folder.Module)
local module = import("./Folder/Module")

-- local module = require(script.Parent.Parent.Module)
local module = import("../Module")

-- local module = require(script.Parent.Parent.Parent.Module)
local module = import("../../Module")
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

Roblox services can be imported by starting the path with them:

```lua
-- local module = require(game.ReplicatedStorage.module)
local module = import("ReplicatedStorage/module")

-- local module = require(game.ServerStorage.module)
local module = import("ServerStorage/module")
```

You can set aliases to define starting points for your paths:

```lua
import.setConfig({
	aliases = {
		shared = game.ReplicatedStorage.Shared
	}
})

-- local module = require(game.ReplicatedStorage.Shared.Module)
local module = import("shared/Module")
```

Works for any Roblox instance, so you can use this to import assets as well:

```lua
-- local sound = script.Parent:FindFirstChild("Sound")
local sound = import("./Sound")

-- local sound = script.Parent:FindFirstChild("Part")
local part = import("./Part")
```

## Development

Install [Rojo](https://github.com/rojo-rbx/rojo/) and then run the following commands:

```sh
$ rojo build -o place.rbxlx
$ rojo serve
```

Open the newly generated place file and start the Rojo plugin.

From here you can modify anything under `src/` and your changes will be synced in.

When you're ready to test, simply press F5 to play the.
