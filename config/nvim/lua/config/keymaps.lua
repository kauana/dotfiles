-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<CR>", "<cmd>w<CR>", { desc = "Save file" })

-- Copy with Cmd+C
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<D-c>", '"+yy', { desc = "Copy line to clipboard" })

-- Paste with Cmd+V
vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste from clipboard" })
vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from clipboard" })
