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

-- ================== SWAP / UNDO HISTORY / AUTOCOMMENT ==================
-- Thu nhỏ cột số dòng
vim.opt.number = true
vim.opt.relativenumber = true -- nếu bạn thích; không bắt buộc
vim.opt.numberwidth = 2 -- mặc định 4; thử 2 (thậm chí 1)

-- Hạn chế cột dấu (signs) chiếm chỗ
vim.opt.signcolumn = "auto:1" -- tối đa 1 cột dấu

-- Ẩn/thu gọn cột gập
vim.opt.foldcolumn = "0" -- hoặc "auto:1" nếu bạn hay gập code

-- (Tuỳ chọn) Giảm bớt dấu LSP để đỡ nở signcolumn
-- Bỏ comment dòng dưới nếu muốn
-- vim.diagnostic.config({ signs = false })

-- (Tuỳ chọn nâng cao) Rút gọn statuscolumn về chỉ hiển thị số
-- Bỏ comment hai dòng dưới nếu thấy bên trái vẫn còn thừa
-- vim.o.statuscolumn = "%=%{v:relnum?v:relnum:v:lnum} "
vim.opt.signcolumn = "no" -- chỉ dùng khi bạn đã quyết định bỏ hết dấu

-- ================== SWAP / UNDO HISTORY / AUTOCOMMENT ==================
-- Tự lưu/tự đọc và ứng xử thân thiện khi có xung đột
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.autoread = true
vim.opt.confirm = true -- hiện hộp thoại khi file ngoài thay đổi
vim.opt.updatetime = 300 -- 300ms để CursorHold nhạy hơn

-- Soft wrap cơ bản
vim.opt.wrap = true -- bật quấn dòng (không chèn \n)
vim.opt.linebreak = true -- ngắt ở khoảng trắng / dấu câu, không cắt giữa từ
vim.opt.breakindent = true -- dòng quấn thụt vào theo indent
vim.opt.breakindentopt = "shift:0" -- thụt thêm 2 spaces cho dòng quấn
vim.opt.showbreak = "↳ " -- ký hiệu ở đầu dòng quấn (tùy thích)
-- vim.opt.smoothscroll = true
-- vim.opt.scrolloff = 6
-- vim.opt.sidescrolloff = 6

-- keymaps.lua (LazyVim)
local opts = { expr = true, silent = true }
vim.keymap.set("n", "j", 'v:count == 0 and "gj" or "j"', opts)
vim.keymap.set("n", "k", 'v:count == 0 and "gk" or "k"', opts)
vim.keymap.set("x", "j", 'v:count == 0 and "gj" or "j"', opts)
vim.keymap.set("x", "k", 'v:count == 0 and "gk" or "k"', opts)
vim.keymap.set("n", "0", 'v:count == 0 and "g0" or "0"', opts)
vim.keymap.set("n", "$", 'v:count == 0 and "g$" or "$"', opts)

vim.opt.mousescroll = "ver:1,hor:6" -- 1 dòng mỗi nấc
