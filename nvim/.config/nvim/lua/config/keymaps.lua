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
vim.keymap.set("n", "<leader>ft", function()
  require("lazyvim.util").terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (file dir)" })

-- Thoát terminal-mode & di chuyển cửa sổ
-- ==== Make <Esc> reliably leave terminal-mode (incl. LazyVim float / Snacks) ====
-- Tối ưu độ trễ Esc (tránh nvim chờ Alt-prefix)
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50 -- 20–80 là hợp lý; 50 khá an toàn

-- ============ BUFFERLINE: GOTO BY ORDINAL (robust) ============
-- Lấy danh sách bufnr theo thứ tự ưu tiên:
-- 1) bufferline (nếu có)  2) LazyVim (vim.t.bufs)  3) buflisted theo bufnr
local function ordered_buffers()
  local ok, bl = pcall(require, "bufferline")
  if ok and type(bl.get_elements) == "function" then
    local ids, els = {}, (bl.get_elements().elements or {})
    for _, e in ipairs(els) do
      if e.id and vim.api.nvim_buf_is_valid(e.id) then
        table.insert(ids, e.id)
      end
    end
    if #ids > 0 then
      return ids
    end
  end

  if type(vim.t.bufs) == "table" and #vim.t.bufs > 0 then
    local ids = {}
    for _, b in ipairs(vim.t.bufs) do
      if vim.api.nvim_buf_is_valid(b) and vim.api.nvim_buf_is_loaded(b) then
        table.insert(ids, b)
      end
    end
    if #ids > 0 then
      return ids
    end
  end

  local infos = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(infos, function(a, b)
    return a.bufnr < b.bufnr
  end)
  local ids = {}
  for _, i in ipairs(infos) do
    table.insert(ids, i.bufnr)
  end
  return ids
end

local function goto_ordinal(n)
  if not n or n < 1 then
    return false
  end
  local bufs = ordered_buffers()
  local target = bufs[n]
  if target then
    vim.api.nvim_set_current_buf(target)
    return true
  end
  return false
end

local function goto_last()
  local bufs = ordered_buffers()
  local last = bufs[#bufs]
  if last then
    vim.api.nvim_set_current_buf(last)
  end
end

local function notify_missing(n)
  vim.notify(("No buffer at ordinal %s"):format(n or "?"), vim.log.levels.WARN)
end

-- Prompt: nhập số thứ tự và nhảy
vim.keymap.set("n", "<A-g>", function()
  vim.ui.input({ prompt = "Go to buffer (ordinal): " }, function(input)
    local n = tonumber(input or "")
    if not (n and goto_ordinal(n)) then
      vim.notify("Invalid ordinal", vim.log.levels.ERROR)
    end
  end)
end, { desc = "Go to buffer by ordinal" })

-- Tạo keymaps gọn cho cả hai kiểu phím: Alt+1..9 và g1..g9; 0 = last
for _, fmt in ipairs({ "<M-%d>", "g%d" }) do
  for i = 1, 9 do
    vim.keymap.set("n", fmt:format(i), function()
      if not goto_ordinal(i) then
        notify_missing(i)
      end
    end, { desc = ("Go to buffer #%d (ordinal)"):format(i) })
  end
end

for _, lhs in ipairs({ "<M-0>", "g0" }) do
  vim.keymap.set("n", lhs, goto_last, { desc = "Go to last buffer (ordinal)" })
end
