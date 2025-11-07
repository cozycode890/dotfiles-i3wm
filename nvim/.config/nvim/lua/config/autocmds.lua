-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- extra autocmds
local aug = vim.api.nvim_create_augroup
local ac = vim.api.nvim_create_autocmd

vim.opt.autoread = true

local G = {
  autosave = aug("autosave_conservative", { clear = true }),
  autoread = aug("autoread_checktime", { clear = true }),
  filenotify = aug("autoread_notify", { clear = true }),
}

local function should_write(buf)
  local bo = vim.bo[buf]
  return bo.buftype == "" -- không phải help/quickfix/terminal...
    and bo.modifiable
    and bo.modified
    and vim.api.nvim_buf_get_name(buf) ~= ""
end

-- AUTO-SAVE: rời insert, rời buffer, mất focus
ac({ "InsertLeave", "BufLeave", "FocusLost" }, {
  group = G.autosave,
  callback = function(args)
    if should_write(args.buf) then
      vim.cmd("silent! update")
    end
  end,
})

-- AUTO-RELOAD: phát hiện thay đổi ngoài
ac({ "FocusGained", "TermClose", "TermLeave", "BufEnter", "CursorHold" }, {
  group = G.autoread,
  command = "checktime",
})

-- Thông báo khi file đã reload do thay đổi ngoài
ac("FileChangedShellPost", {
  group = G.filenotify,
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
