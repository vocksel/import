# import

This module allows you to write paths for Roblox instances like you do on the filesystem.

Having to constantly type `script.Parent` with varying levels of `.Parent` is tedious and can produce excessively long lines. This module aims to fix this by providing a concise syntax for writing import paths that closely resembles what's used on the filesystem.

## Download

Download the latest version from the [releases page](https://github.com/vocksel/import/releases) or from the [asset library](https://www.roblox.com/library/7218303036/import)

## Usage

```lua
local import = require(game.ReplicatedStorage.Import)

local module = import("./ModuleScript")
-- local module = require(script.Parent.ModuleScript)

local module = import("./Folder/ModuleScript)"
-- local module = require(script.Parent.Folder.ModuleScript)

local module = import("../ModuleScript")
-- local module = require(script.Parent.Parent.ModuleScript)

local module = import("../../ModuleScript")
-- local module = require(script.Parent.Parent.Parent.ModuleScript)
```

To get easy access to the children of Roblox services, you can use absolute paths by starting a path with a slash `/`.

```lua
local module = import("/ReplicatedStorage/ModuleScript")
-- local module = require(game.ReplicatedStorage.ModuleScript)
```

The import function also provides a destructuring syntax that allows you to import individual members of a module.

```lua
local foo = import("./ModuleScript", { "foo" })
-- local foo = require(script.Parent.ModuleScript).foo

local foo, bar = import("./ModuleScript", { "foo", "bar" })
-- local module = require(script.Parent.ModuleScript)
-- local foo = module.foo
-- local bar = module.bar
```

And this function isn't just for ModuleScripts! You can import any Instance with the path syntax.

```lua
local sound = import("./Sound")
-- local sound = script.Parent.Sound

local part = import("./Part")
-- local part = script.Parent.Part
```

## Aliases

Aliases are a powerful method of defining custom starting points for paths.

A common usecase for this is to define entrypoints to your server, client, and shared code. For example:

```lua
local import = require(game.ReplicatedStorage.import)

import.setAliases({
	server = game.ServerScriptService.ServerModules,
	client = game.StarterPlayer.StarterPlayerScripts.ClientModules,
	shared = game.ReplicatedStorage.SharedModules,
})

local module = import("shared/ModuleScript")
-- local module = require(game.ReplicatedStorage.SharedModules.ModuleScript)
```

There is also a built-in `script` alias that allows you to import the descendants of the script that is calling `import()`.

```lua
local module = import("script/ModuleScript")
-- local module = require(script.ModuleScript)
```

## Config

There are several configuration values you can customize to fit your needs.

Name | Description | Default
:-- | :-- | :--
`root` | Controls the root Instance for absolute paths. This is especially helpful when using this module in a package or plugin | `game`
`useWaitForChild` | By default, FindFirstChild is used when traversing the hierarchy. Set to `true` to use WaitForChild instead | false
`waitForChildTimeout` | When `useWaitForChild` is set to `true`, this controls how long (in seconds) to yield before resolving | 1
`scriptAlias` | Controls the name of the alias that is reserved for the current script | `"script"`
`detectRequireLoops` | By default, `import` will throw an error when ModuleScripts attempt to require eachother in a recursive loop (which would otherwise silently fail). This feature was designed with the assumption the user only has a singular Script or LocalScript as the entry point to the codebase, and this feature can be disabled if it causes problems | true

```lua
local import = require(game.ReplicatedStorage.import)

import.setConfig({
	useWaitForChild = true,
	scriptAlias = "@",
})

local module = import("@/ModuleScript")
-- local module = require(script:WaitForChild("ModuleScript"))
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

# Or build the project. Drag and drop into Roblox Studio to insert it
rojo build -o import.rbxmx
```

## License

MIT
