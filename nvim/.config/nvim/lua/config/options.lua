-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- options.lua (compact)
local o, a = vim.opt, vim.api

-- ── Status bar ──────────────────────────────────────────────────────────
o.laststatus = 3

-- ── Files / Undo / History / Autocomment ────────────────────────────────
o.swapfile = false
o.undofile = true
local dir = vim.fn.stdpath("state") .. "/undo" -- hoặc "data"
vim.opt.undodir = dir
vim.opt.undofile = true
pcall(vim.fn.mkdir, dir, "p") -- đảm bảo thư mục tồn tại
o.history = 10000

local aug = a.nvim_create_augroup("NoAutoComment", { clear = true })
a.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = aug,
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ── Gutter / Cột trái ───────────────────────────────────────────────────
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.foldcolumn = "0"

-- Toggle ẩn hết dấu (LSP/Git…); để false nếu còn cần diagnostics/gitsigns
local HIDE_SIGNS = false
o.signcolumn = HIDE_SIGNS and "no" or "auto:1"

-- (tuỳ chọn) statuscolumn chỉ hiển thị số dòng:
-- o.statuscolumn = "%=%{v:relnum?v:relnum:v:lnum} "

-- ── Auto write / read & confirm ─────────────────────────────────────────
o.autowrite = true
o.autowriteall = true
o.autoread = true
o.confirm = true

-- ── Soft wrap dễ đọc ────────────────────────────────────────────────────
o.wrap = true
o.linebreak = true
o.breakindent = true
o.breakindentopt = "shift:0" -- không thụt thêm; đổi số nếu bạn muốn thụt
o.showbreak = "↳ "

-- ── Cuộn & hiệu năng nhẹ nhàng ──────────────────────────────────────────
o.mousescroll = "ver:1,hor:6"
o.lazyredraw = false
o.updatetime = 200

-- ── Keymaps: j/k = gj/gk khi không có count ─────────────────────────────
local expr_opts = { expr = true, silent = true }
for _, mode in ipairs({ "n", "x" }) do
  vim.keymap.set(mode, "j", 'v:count==0 and "gj" or "j"', expr_opts)
  vim.keymap.set(mode, "k", 'v:count==0 and "gk" or "k"', expr_opts)
end

-- require("config/kitty_title").setup()
