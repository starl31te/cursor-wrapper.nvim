# cursor-wrapper.nvim

A simple Neovim plugin to interact with the `cursor-agent` command-line tool, bringing AI chat and context directly into your editor.



## Features

-   💬 Open a chat terminal with the context of the current file or visual selection.
-   🚀 Send context as either the full text content or just the file path.
-   📜 Automatically prepend a file of predefined "rules" to your prompts.
-   ⌨️ Configure the chat window's position and size.

## Requirements

-   Neovim >= 0.8
-   The `cursor-agent` command-line tool installed and available in your `PATH`.

## Installation

Install with your favorite plugin manager. Here is an example using `lazy.nvim`.

```lua
-- In your plugins setup file, e.g., lua/plugins/cursor-wrapper.lua

return {
    'starl31te/cursor-wrapper.nvim',

    config = function()
        local cursor_wrapper = require("cursor-wrapper")

        -- 1. Call the setup function with your desired options
        cursor_wrapper.setup({
            context_method = 'text',
            split_position  = 'right',
            split_size = 0.4,
            rules_path = vim.fn.expand("~/.cursor/rules/rules.md")
        })

        -- 2. Set your keymaps
        vim.keymap.set({ "n", "v" }, "<leader>cc", cursor_wrapper.open_cursor_terminal, {
            desc = "Toggle Cursor chat with context",
        })

        vim.keymap.set("n", "<leader>cn", cursor_wrapper.open_cursor_terminal_no_context, {
            desc = "Toggle Cursor chat without context",
        })

        vim.keymap.set("t", "<Esc><Esc>", cursor_wrapper.smart_escape, {
            desc = "Exit Cursor Chat terminal",
            silent = true,
        })
    end,
}
```

## Configuration

The plugin is configured by passing a table to the `setup()` function.

### Options

Here are the available options with their default values:

| Option             | Type   | Default   | Description                                                                                               |
| ------------------ | ------ | --------- | --------------------------------------------------------------------------------------------------------- |
| `context_method`   | string | `'text'`  | How to send context. `'text'` sends file content, `'path'` sends the file path and line numbers.          |
| `split_position`   | string | `'right'` | Where to open the chat window. Can be `'right'`, `'left'`, `'top'`, or `'bottom'`.                            |
| `split_size`       | number | `0.4`     | The percentage of the screen the chat window should occupy (e.g., `0.4` for 40%).                          |
| `rules_path`       | string | `nil`     | Absolute path to a markdown file with rules to prepend to every prompt. If `nil` or file doesn't exist, it's ignored. |

### Keymaps

You can map the plugin's functions to any keys you like. Here is the example from the installation section:

-   `<leader>cc` (Normal and Visual modes): Opens the chat with context. If you're in visual mode, it sends the selection; otherwise, it sends the whole file.
-   `<leader>cn` (Normal mode): Opens the chat without any context.
-   `<Esc><Esc>` (Terminal mode): Exits the chat terminal's insert mode and returns you to normal mode.

## License

MIT
