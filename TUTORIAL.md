# Neovim Configuration Tutorial

This tutorial will guide you through the main features and keybindings of your Neovim setup.

## General Keybindings

These are some global keybindings defined in your `init.lua`:

-   `<leader>` key: The leader key is set to the `space` bar. This key is used for many custom shortcuts.
-   `<localleader>` key: The local leader key is set to `\`.
-   `<leader>w`: Save the current file.

## Plugins

### Which-Key

-   **Purpose**: Displays available keybindings.
-   **Usage**: When you press a key that is part of a keybinding, a popup will appear showing you the possible next keys. For example, if you press `<leader>`, a popup will show all the available keybindings that start with `<leader>`.
-   **Keybindings**:
    -   `<leader>?`: Show buffer local keymaps.

### Autopairs

-   **Purpose**: Automatically closes pairs of brackets, parentheses, quotes, etc.
-   **Usage**: When you type an opening bracket, the closing bracket is automatically inserted.

### Bufferline

-   **Purpose**: Displays a line at the top of the editor with all your open buffers.
-   **Usage**: You can click on the buffer names to switch between them, or use keyboard shortcuts.
-   **Keybindings**:
    -   `<C-l>`: Go to the next buffer.
    -   `<C-h>`: Go to the previous buffer.

### Codeium

-   **Purpose**: Provides AI-powered code completion.
-   **Usage**: As you type, Codeium will suggest completions.
-   **Keybindings**:
    -   `<C-g>`: Accept a completion.
    -   `<c-;>`: Cycle to the next completion.
    -   `<c-,>`: Cycle to the previous completion.
    -   `<c-x>`: Clear the current completion.

### Colorizer

-   **Purpose**: Highlights color codes (e.g., `#FFFFFF`, `rgb(255, 255, 255)`) with their actual color.
-   **Usage**: This works automatically.

### Comment

-   **Purpose**: Easily comment and uncomment lines of code.
-   **Keybindings**:
    -   `gcc`: Toggle comment for the current line.
    -   `gc` + `motion` (e.g., `gcG`, `gcgg`): Toggle comment for a range of lines.

### Conform

-   **Purpose**: Formats your code automatically.
-   **Usage**: This plugin is configured to format your code every time you save a file. It is currently set up to format markdown files with `prettierd`.

### Gitsigns

-   **Purpose**: Shows git information in the sign column (the column on the left of the line numbers).
-   **Usage**: You will see `+` for added lines, `~` for changed lines, and `-` for deleted lines.
-   **Keybindings**:
    -   `]c`: Go to the next hunk.
    -   `[c`: Go to the previous hunk.
    -   `<leader>hs`: Stage the current hunk.
    -   `<leader>hr`: Reset the current hunk.
    -   `<leader>hp`: Preview the current hunk.
    -   `<leader>hb`: Blame the current line.

### Illuminate

-   **Purpose**: Highlights other occurrences of the word under your cursor.
-   **Usage**: This works automatically.

### Indent-Blankline

-   **Purpose**: Adds indentation guides to your code.
-   **Usage**: This works automatically.

### LSP (Language Server Protocol)

-   **Purpose**: Provides language-specific features like auto-completion, go to definition, and diagnostics.
-   **Usage**: This plugin is the core of the IDE-like features in your setup. It uses `mason` to manage LSP servers.
-   **Keybindings**:
    -   `K`: Show hover information for the word under the cursor.
    -   `gd`: Go to the definition of the word under the cursor.
    -   `gD`: Go to the declaration of the word under thecursor.
    -   `gi`: Go to the implementation of the word under the cursor.
    -   `gr`: Show references to the word under the cursor.
    -   `<leader>ca`: Show code actions.
    -   `[d`: Go to the previous diagnostic.
    -   `]d`: Go to the next diagnostic.

### Lualine

-   **Purpose**: A statusline for Neovim.
-   **Usage**: The statusline at the bottom of the editor provides information about the current file, git branch, etc.

### NvimTree

-   **Purpose**: A file explorer.
-   **Keybindings**:
    -   `<leader>e`: Toggle the file explorer.
    -   `?`: Toggle help.
    -   `<CR>`: Open a file or folder.
    -   `a`: Create a new file.
    -   `d`: Delete a file.
    -   `r`: Rename a file.
    -   `x`: Cut a file.
    -   `c`: Copy a file.
    -   `p`: Paste a file.
    -   `q`: Close the file explorer.

### Symbols-Outline

-   **Purpose**: Shows a symbol outline of the current file.
-   **Keybindings**:
    -   `<leader>o`: Toggle the symbols outline.

### Telescope

-   **Purpose**: A fuzzy finder for files, buffers, etc.
-   **Keybindings**:
    -   `<leader>ff`: Find files.
    -   `<leader>fg`: Find git files.
    -   `<leader>fl`: Live grep.
    -   `;`: Find buffers.
    -   `<leader>fh`: Find help tags.

### Treesitter

-   **Purpose**: Provides more accurate syntax highlighting and other language parsing features.
-   **Usage**: This works automatically.
