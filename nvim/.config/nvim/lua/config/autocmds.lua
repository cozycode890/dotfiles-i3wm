-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ========== AUTO-SAVE ==========
local function should_write(buf)
  if vim.bo[buf].buftype ~= "" then
    return false
  end -- bỏ help/quickfix/terminal...
  if not vim.bo[buf].modifiable then
    return false
  end
  if vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end
  return vim.bo[buf].modified
end

-- Hồ sơ "bảo thủ": lưu khi rời insert, rời buffer, mất focus
vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost" }, {
  callback = function(args)
    if should_write(args.buf) then
      pcall(vim.cmd, "silent! update")
    end
  end,
})

-- Hồ sơ "tích cực": lưu sau khi đứng yên 1 nhịp (dựa trên updatetime)
-- Bỏ comment nếu bạn muốn tự lưu thường xuyên hơn
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   callback = function(args)
--     if should_write(args.buf) then
--       pcall(vim.cmd, "silent! update")
--     end
--   end,
-- })

-- ========== AUTO-RELOAD KHI FILE BÊN NGOÀI ĐỔI ==========
-- Gọi :checktime vào các thời điểm hợp lý để phát hiện thay đổi
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- Thông báo khi đã reload do thay đổi ngoài
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function(info)
    local msg = ("File đã thay đổi trên đĩa và được nạp lại: %s"):format(info.file or "")
    local ok, notify = pcall(require, "notify")
    if ok then
      notify(msg, vim.log.levels.WARN, { title = "autoread" })
    else
      vim.notify(msg, vim.log.levels.WARN)
    end
  end,
})
