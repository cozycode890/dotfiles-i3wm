-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- ================== SWAP / UNDO HISTORY / AUTOCOMMENT ==================
-- Tắt swapfile
vim.opt.swapfile = false

-- Bật lịch sử undo bền (persistent undo) + thư mục lưu
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- Tăng dung lượng history cho lệnh/tìm kiếm (không phải undo)
vim.opt.history = 10000

-- Tắt tự động thêm comment khi xuống dòng (o/O/Enter)
-- Loại bỏ c, r, o cho mọi buffer vì plugin có thể bật lại
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = vim.api.nvim_create_augroup("NoAutoComment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
