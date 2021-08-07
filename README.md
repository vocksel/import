# import

This module allows you to write paths for Roblox instances like you do on the filesystem.

Having to constantly type `script.Parent` with varying levels of `.Parent` is tedious and can produce excessively long lines. This module aims to fix this by providing a concise syntax for writing import paths that closely resembles what's used on the filesystem.

## Download

Download the latest version from the [releases page](https://github.com/vocksel/import/releases) or from the [asset library](https://www.roblox.com/library/7218303036/import)

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

-- local part = script.Parent:FindFirstChild("Part")
local part = import "./Part"
```

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

You will need [Rust](https://www.rust-lang.org/) 1.41.0+ and the [Rojo plugin](https://www.roblox.com/library/4048317704/Rojo-6). If you use VS Code, you can install the [Rojo extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo) which manages the plugin for you and makes it easier to serve the project.

It is also recommended that you add `~/.foreman/bin` to your `PATH` to make the tools that Foreman installs for you accessible on your system.

```sh
# Cargo is Rust's package manager, Foreman is our toolchain manager
cargo install foreman

# Install Rojo and other tools we use
foreman install

# Serve the project. Use the Rojo plugin in Roblox Studio to connect
rojo serve dev.project.json

# Or build the Dev Module as a model file. Drag and drop into Roblox Studio to insert it
rojo build -o dev-module.rbxmx
```

## License

MIT
