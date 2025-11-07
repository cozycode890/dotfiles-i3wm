-- lua/plugins/iron.lua
return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      opts.spec[#opts.spec + 1] = { "<leader>i", group = "+REPL (iron)", mode = { "n", "v" } }
    end,
  },

  {
    "hkupty/iron.nvim",
    event = { "BufReadPost", "BufNewFile" },

    keys = function()
      local api, fn = vim.api, vim.fn

      -- ===== Helpers =====
      local function strip_special(s)
        return (s or "")
          :gsub("\r", "")
          :gsub("\239\187\191", "") -- BOM
          :gsub("\226\128\139", "") -- ZWSP
          :gsub("\194\160", " ") -- NBSP -> space
      end

      local function keep_line(l)
        local s = strip_special(l)
        return not s:match("^%s*$") and not s:match("^%s*#")
      end

      local function filter_lines(lines)
        local out = {}
        for _, l in ipairs(lines) do
          if keep_line(l) then
            out[#out + 1] = l
          end
        end
        return out
      end

      local function send_to_repl(text)
        if not text or text == "" then
          return
        end
        local iron = require("iron.core")
        local lines = filter_lines(vim.split(text, "\n", { plain = true }))
        if #lines > 0 then
          iron.send(nil, table.concat(lines, "\n") .. "\n")
        end
      end

      local function get_visual_text()
        local bufnr = 0
        local mode = fn.visualmode()
        local vstart, vend = fn.getpos("v"), fn.getpos(".")
        local srow, scol, erow, ecol = vstart[2], vstart[3], vend[2], vend[3]
        if srow > erow or (srow == erow and scol > ecol) then
          srow, erow, scol, ecol = erow, srow, ecol, scol
        end
        local function slice(line, c1, c2)
          c1 = math.max(1, math.min(#line + 1, c1))
          c2 = math.max(1, math.min(#line + 1, c2))
          if c2 < c1 then
            c1, c2 = c2, c1
          end
          return string.sub(line, c1, c2)
        end

        if mode == "V" then
          return table.concat(api.nvim_buf_get_lines(bufnr, srow - 1, erow, false), "\n")
        elseif mode == "\022" then
          local out = {}
          for r = srow, erow do
            local line = api.nvim_buf_get_lines(bufnr, r - 1, r, false)[1] or ""
            out[#out + 1] = slice(line, scol, ecol)
          end
          return table.concat(out, "\n")
        else
          local lines = api.nvim_buf_get_lines(bufnr, srow - 1, erow, false)
          if #lines == 0 then
            return ""
          end
          if #lines == 1 then
            return slice(lines[1], scol, ecol)
          end
          lines[1] = slice(lines[1], scol, #lines[1] + 1)
          lines[#lines] = slice(lines[#lines], 1, ecol)
          return table.concat(lines, "\n")
        end
      end

      local function send_paragraph()
        local bufnr = 0
        local row = api.nvim_win_get_cursor(0)[1]
        local last = api.nvim_buf_line_count(bufnr)

        local s = row
        while s > 1 do
          local l = api.nvim_buf_get_lines(bufnr, s - 2, s - 1, false)[1] or ""
          if l:match("^%s*$") then
            break
          end
          s = s - 1
        end

        local e = row
        while e < last do
          local l = api.nvim_buf_get_lines(bufnr, e, e + 1, false)[1] or ""
          if l:match("^%s*$") then
            break
          end
          e = e + 1
        end

        send_to_repl(table.concat(api.nvim_buf_get_lines(bufnr, s - 1, e, false), "\n"))
      end

      -- ===== Keymaps =====
      local M = {}

      -- lifecycle
      M[#M + 1] = { "<leader>io", "<cmd>IronRepl<cr>", desc = "Open REPL (bottom)", mode = "n" }
      M[#M + 1] = { "<leader>ir", "<cmd>IronRestart<cr>", desc = "Restart REPL", mode = "n" }
      M[#M + 1] = { "<leader>if", "<cmd>IronFocus<cr>", desc = "Focus REPL", mode = "n" }
      M[#M + 1] = { "<leader>ih", "<cmd>IronHide<cr>", desc = "Hide REPL", mode = "n" }

      -- send (đã “clean”)
      M[#M + 1] = {
        "<leader>il",
        function()
          send_to_repl(api.nvim_get_current_line())
        end,
        desc = "Send line (clean)",
        mode = "n",
      }

      M[#M + 1] = {
        "<leader>is",
        function()
          send_to_repl(get_visual_text())
        end,
        desc = "Send selection (clean)",
        mode = "x",
      }

      M[#M + 1] = {
        "<leader>ip",
        function()
          send_paragraph()
        end,
        desc = "Send paragraph (clean)",
        mode = "n",
      }

      M[#M + 1] = {
        "<leader>iF",
        function()
          local lines = api.nvim_buf_get_lines(0, 0, -1, false)
          send_to_repl(table.concat(lines, "\n"))
        end,
        desc = "Send whole file (clean)",
        mode = "n",
      }

      return M
    end,

    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")
      local common = require("iron.fts.common")

      iron.setup({
        config = {
          repl_definition = {
            python = { command = { "ipython", "--no-autoindent" }, format = common.bracketed_paste },
            r = { command = { "R", "--quiet", "--no-save" }, format = common.bracketed_paste },
            sh = { command = { "bash" } },
          },
          repl_open_cmd = view.split.belowright(8),
          scratch_repl = true,
          should_map_plug = false,
          close_window_on_exit = true,
          highlight_last = "IronLastSent",
          highlight = { italic = true },
          ignore_blank_lines = true, -- vẫn tự lọc để chắc chắn
        },
      })
    end,
  },
}
