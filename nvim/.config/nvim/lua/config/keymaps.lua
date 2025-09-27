-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ============ INDENT WITH TAB / UNINDENT WITH S-TAB ============
-- Normal mode: indent current line
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })

-- Visual mode: indent selection and keep it selected
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

-- (Tùy chọn) Nếu thật sự muốn trong Insert mode (có thể ảnh hưởng nvim-cmp)
-- Tăng/giảm thụt lề tại Insert (chuẩn Vim)
-- vim.keymap.set("i", "<Tab>", "<C-t>", { desc = "Indent (insert)" })
-- vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent (insert)" })
