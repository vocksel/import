# import

[![CI](https://github.com/vocksel/import/actions/workflows/ci.yml/badge.svg)](https://github.com/vocksel/import/actions/workflows/ci.yml)

This package allows you to write paths for Roblox instances like you do on the filesystem. It comes with support for aliases, individual exports, and works for any instance.
## Installation

### Wally

If you are using [Wally](https://github.com/UpliftGames/wally), add the following to your `wally.toml` and run `wally install` to get a copy of the package.

```
[dependencies]
import = "vocksel/import@2.1.0
```

### Model File

Download the latest release from the [asset library](https://www.roblox.com/library/7218303036/import).

## Motivation

Having to type `script.Parent` with varying levels of `.Parent` is tedious and can produce excessively long require statements.

This module aims to fix that by providing a concise syntax for writing import paths that closely resembles what is used on the filesystem.

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
```

You can then use these aliases as keywords at the beginning of your paths:

```lua
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
```lua
local import = require(game.ReplicatedStorage.import)

import.setConfig({
	useWaitForChild = true,
	scriptAlias = "@",
})

local module = import("@/ModuleScript")
-- local module = require(script:WaitForChild("ModuleScript"))
```

## Contributing

See the [contributing guide](CONTRIBUTING.md).

## License

[MIT License](LICENSE)
