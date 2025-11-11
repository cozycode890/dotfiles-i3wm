-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- ============ INDENT WITH TAB / UNINDENT WITH S-TAB ============
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent selection" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent selection" })

-- (Optional) Insert-mode indent (có thể ảnh hưởng nvim-cmp)
vim.keymap.set("i", "<Tab>", "<C-t>", { desc = "Indent (insert)" })
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent (insert)" })

-- ============ SMART i / a  ============
local function in_leading_spaces()
  local col = vim.fn.col(".")
  local first = vim.fn.indent(vim.fn.line(".")) + 1
  if col < first then
    local ch = vim.fn.getline("."):sub(col, col)
    return ch == " " or ch == "\t"
  end
  return false
end

vim.keymap.set("n", "i", function()
  return in_leading_spaces() and "I" or "i"
end, { expr = true, desc = "Smart i → go to indent if in leading spaces" })

vim.keymap.set("n", "a", function()
  return in_leading_spaces() and "^i" or "a"
end, { expr = true, desc = "Smart a → go to indent if in leading spaces" })

-- ============ TERMINAL (mở tại thư mục file hiện tại) ============
-- Terminal ở thư mục của file hiện tại local
Util = require("lazyvim.util")

vim.keymap.set("n", "<leader>ft", function()
  Util.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (file dir)" })

-- Thoát terminal-mode & di chuyển cửa sổ
-- ==== Make <Esc> reliably leave terminal-mode (incl. LazyVim float / Snacks) ====
-- Tối ưu độ trễ Esc (tránh nvim chờ Alt-prefix)
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50 -- 20–80 là hợp lý; 50 khá an toàn

local function tmap(lhs, rhs, opts)
  vim.keymap.set("t", lhs, rhs, vim.tbl_extend("force", { silent = true, noremap = true }, opts or {}))
end

local grp = vim.api.nvim_create_augroup("BetterTermEsc", { clear = true })

vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
  group = grp,
  callback = function(ev)
    -- Lấy filetype của buffer terminal hiện tại
    local ft = vim.bo[ev.buf].filetype

    -- ===== THAY THẾ 'yazi' bên dưới =====
    -- Thay 'yazi' bằng filetype bạn tìm thấy ở Bước 1
    -- Ví dụ: nếu filetype là 'toggleterm', thì viết: if ft == 'toggleterm' then
    if ft == "yazi" then
      -- Nếu đây là terminal của Yazi, chúng ta KHÔNG map <Esc>.
      -- Bạn có thể quyết định có map các phím điều hướng C-h/j/k/l hay không.
      -- Nếu Yazi không dùng C-h/j/k/l, bạn có thể giữ chúng.
      -- Nếu muốn Yazi toàn quyền, chỉ cần 'return' ở đây.

      -- Ví dụ: Vẫn map điều hướng nhưng bỏ qua Esc
      tmap("<C-h>", [[<C-\><C-n><C-w>h]], { buffer = ev.buf })
      tmap("<C-j>", [[<C-\><C-n><C-w>j]], { buffer = ev.buf })
      tmap("<C-k>", [[<C-\><C-n><C-w>k]], { buffer = ev.buf })
      tmap("<C-l>", [[<C-\><C-n><C-w>l]], { buffer = ev.buf })
      return -- Rất quan trọng: dừng lại để không map <Esc> bên dưới
    end

    -- Nếu KHÔNG phải Yazi (là terminal thông thường):
    -- buffer-local để “ăn” ngay trong terminal hiện tại
    tmap("<Esc>", [[<C-\><C-n>]], { buffer = ev.buf, nowait = true })

    -- điều hướng cửa sổ khi đang ở terminal
    tmap("<C-h>", [[<C-\><C-n><C-w>h]], { buffer = ev.buf })
    tmap("<C-j>", [[<C-\><C-n><C-w>j]], { buffer = ev.buf })
    tmap("<C-k>", [[<C-\><C-n><C-w>k]], { buffer = ev.buf })
    tmap("<C-l>", [[<C-\><C-n><C-w>l]], { buffer = ev.buf })
  end,
})

-- ============ BUFFERLINE: GOTO BY ORDINAL (robust) ============
local function bl_goto_ordinal(n)
  local ok, bl = pcall(require, "bufferline")
  if ok and type(bl.get_elements) == "function" then
    local els = bl.get_elements().elements or {}
    local el = els[n]
    if el and el.id then
      vim.api.nvim_set_current_buf(el.id)
      return true
    end
    return false
  end
  -- Fallback: listed buffers in display order if available (LazyVim), else bufnr sort
  local listed = vim.t.bufs or {}
  if #listed > 0 then
    local b = listed[n]
    if b and vim.api.nvim_buf_is_loaded(b) then
      vim.api.nvim_set_current_buf(b)
      return true
    end
  end
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(bufs, function(a, b)
    return a.bufnr < b.bufnr
  end)
  local target = bufs[n]
  if target then
    vim.api.nvim_set_current_buf(target.bufnr)
    return true
  end
  return false
end

local function bl_goto_last()
  local ok, bl = pcall(require, "bufferline")
  if ok and type(bl.get_elements) == "function" then
    local els = bl.get_elements().elements or {}
    local last = els[#els]
    if last and last.id then
      vim.api.nvim_set_current_buf(last.id)
      return
    end
  end
  local listed = vim.t.bufs or {}
  if #listed > 0 then
    vim.api.nvim_set_current_buf(listed[#listed])
    return
  end
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 0 then
    vim.api.nvim_set_current_buf(bufs[#bufs].bufnr)
  end
end

-- Prompt: enter an ordinal and jump
vim.keymap.set("n", "<A-g>", function()
  vim.ui.input({ prompt = "Go to buffer (ordinal): " }, function(input)
    local n = tonumber(input or "")
    if not n or not bl_goto_ordinal(n) then
      vim.notify("Invalid ordinal", vim.log.levels.ERROR)
    end
  end)
end, { desc = "Go to buffer by ordinal" })

-- Keymaps:
-- 1) Alt+1..9 (works only if your WM/terminal doesn’t swallow Alt)
for i = 1, 9 do
  vim.keymap.set("n", ("<M-%d>"):format(i), function()
    if not bl_goto_ordinal(i) then
      vim.notify("No buffer at ordinal " .. i, vim.log.levels.WARN)
    end
  end, { desc = ("Go to buffer #%d (ordinal)"):format(i) })
end
vim.keymap.set("n", "<M-0>", bl_goto_last, { desc = "Go to last buffer (ordinal)" })

-- 2) Guaranteed in-terminal fallback keys (use these if Alt is intercepted):
for i = 1, 9 do
  vim.keymap.set("n", ("g%d"):format(i), function()
    if not bl_goto_ordinal(i) then
      vim.notify("No buffer at ordinal " .. i, vim.log.levels.WARN)
    end
  end, { desc = ("Go to buffer #%d (ordinal)"):format(i) })
end
vim.keymap.set("n", "g0", bl_goto_last, { desc = "Go to last buffer (ordinal)" })
