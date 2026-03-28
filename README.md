# Neovim Setup

## Prerequisites

Install the latest version of Neovim

```bash
brew install neovim
```

and install ripgrep

```bash
brew install ripgrep
```

and lazygit

```bash
brew install lazygit
```

Then create the config directory

```bash
mkdir ~/.config/nvim
```

and then clone the git config

```bash
git clone <https://the.repo.....>
```

finally, open Neovim with the following command

```bash
nvim
```

## Optional Configuration

This configuration includes an example file for local settings that will not be tracked by git. You can use this to override default settings on a specific machine.

Copy the example file:

```bash
cp lua/config/example_local.lua lua/config/local.lua
```

Then, edit `lua/config/local.lua` to enable or disable features.

### Disable lazy.nvim auto-update

To disable the automatic update checker for `lazy.nvim`, open `lua/config/local.lua` and uncomment the `disable_lazy_update_checker` line:

```lua
return {
  -- To disable lazy.nvim's auto update checker, uncomment the following line
  disable_lazy_update_checker = true,
}
```