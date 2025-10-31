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

-- Xoá các map mặc định mà LazyVim đặt cho tìm files/grep
-- vim.schedule(function()
--   pcall(vim.keymap.del, "n", "<leader>ff")
--   pcall(vim.keymap.del, "n", "<leader>fF")
--   pcall(vim.keymap.del, "n", "<leader>fg")
-- end)

-- Explorer tại thư mục của file đang mở
vim.keymap.set("n", "<leader>e", function()
  local Snacks = require("snacks")
  local bufpath = vim.api.nvim_buf_get_name(0)
  local dir = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":p:h")) or vim.uv.cwd()
  Snacks.explorer({ cwd = dir })
end, { desc = "Explorer (buffer's directory)" })

-- Explorer theo root (LSP → .git → cwd)
vim.keymap.set("n", "<leader>E", function()
  require("snacks").explorer() -- để Snacks tự chọn root theo vim.g.root_spec
end, { desc = "Explorer (project root by spec)" })

vim.keymap.set("n", "<leader>fg", function()
  require("snacks").picker.grep({
    cmd = "rg",
    args = { "--hidden", "--glob", "!**/.git/**" },
  })
end, { desc = "Find Text" })
