-- lua/plugins/lsp_ui.lua (tinh gọn)
return {
  -- 1) LSP core: float viền tròn, diagnostics gọn, inlay hints an toàn API, hover yên lặng
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function(_, opts)
      -- tắt semantic tokens (giữ nguyên phần có sẵn)
      opts.semantic_tokens = vim.tbl_deep_extend("force", opts.semantic_tokens or {}, {
        enabled = false,
      })

      -- gộp thêm servers thay vì ghi đè
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        pyright = {
          -- thêm ipynb nếu bạn dùng Molten/Jupytext
          filetypes = { "python", "ipynb" },
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                -- giảm đụng với Ruff
                diagnosticMode = "openFilesOnly",
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                  reportShadowedImports = "none",
                },
              },
            },
          },
        },
        ruff_lsp = {
          on_attach = function(client, _)
            -- để pyright lo hover
            client.server_capabilities.hoverProvider = false
          end,
          -- init_options = { settings = { } }, -- (tuỳ chọn)
        },
      })

      return opts
    end,
    init = function()
      local BORDER = "rounded"

      ----------------------------------------------------------------------
      -- Float: viền & size mặc định cho mọi popup LSP
      ----------------------------------------------------------------------
      local ofp = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or BORDER
        opts.max_width = opts.max_width or 84
        opts.max_height = opts.max_height or 24
        return ofp(contents, syntax, opts, ...)
      end

      ----------------------------------------------------------------------
      -- Signs + Diagnostics
      ----------------------------------------------------------------------
      for t, icon in pairs({ Error = " ", Warn = " ", Hint = " ", Info = " " }) do
        local hl = "DiagnosticSign" .. t
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = {
          spacing = 2,
          prefix = "●",
          source = "if_many",
          severity = { min = vim.diagnostic.severity.WARN },
        },
        float = { border = BORDER, source = "if_many", header = "", focusable = false },
      })

      ----------------------------------------------------------------------
      -- Hover yên lặng trên CursorHold (không spam, có cuộn, tránh tự reset)
      ----------------------------------------------------------------------
      local H = _G.__LSP_HOVER__ or { enabled = true, truncate = false, last_win = nil, last_buf = nil }
      _G.__LSP_HOVER__ = H

      local function make_pos_params(bufnr, win)
        local util = vim.lsp.util
        local client = (vim.lsp.get_clients({ buf = bufnr or 0 }) or {})[1]
        local enc = (client and client.offset_encoding) or "utf-16"
        if util.make_position_params then
          local ok, p = pcall(util.make_position_params, win or 0, enc)
          if ok and p then
            return p
          end
          ok, p = pcall(util.make_position_params, bufnr or 0)
          if ok and p then
            return p
          end
        end
        local pos = vim.api.nvim_win_get_cursor(win or 0)
        return {
          textDocument = util.make_text_document_params(bufnr or 0),
          position = { line = pos[1] - 1, character = pos[2] },
        }
      end

      local function to_md_lines(contents)
        local util = vim.lsp.util
        local lines = util.convert_input_to_markdown_lines and util.convert_input_to_markdown_lines(contents)
          or (type(contents) == "string" and vim.split(contents, "\n", { trimempty = false }))
          or {}
        local a, b = 1, #lines
        while a <= b and (lines[a] == nil or lines[a] == "") do
          a = a + 1
        end
        while b >= a and (lines[b] == nil or lines[b] == "") do
          b = b - 1
        end
        return (b >= a) and vim.list_slice(lines, a, b) or {}
      end

      local function supports(bufnr, method)
        for _, c in ipairs(vim.lsp.get_clients({ buf = bufnr })) do
          local cap = c.server_capabilities or {}
          if method == "textDocument/hover" and cap.hoverProvider then
            return true
          end
        end
        return false
      end

      local function hover_quiet(opts)
        local bufnr = 0
        if not supports(bufnr, "textDocument/hover") then
          return -- im lặng, không gửi request => hết thông báo “not supported…”
        end
        local params = make_pos_params(bufnr, 0)
        vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
          if err or not result or not result.contents then
            return
          end
          if err or not result or not result.contents then
            return
          end
          local lines = to_md_lines(result.contents)
          if vim.tbl_isempty(lines) then
            return
          end

          opts = opts or {}
          if (opts.truncate ~= false) and #lines > (opts.max_lines or 30) then
            local maxl = opts.max_lines or 30
            local more = #lines - maxl
            lines = vim.list_slice(lines, 1, maxl)
            table.insert(lines, "")
            table.insert(lines, ("… (%d more lines truncated)"):format(more))
          end

          local buf, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
            border = opts.border or BORDER,
            focusable = false,
            focus_id = "hover-quiet",
            max_width = opts.max_width or 84,
            max_height = opts.max_height or 24,
          })
          H.last_win, H.last_buf = win, buf
        end)
      end

      -- CursorHold trigger (thay LspHoverHold)
      pcall(vim.api.nvim_del_augroup_by_name, "LspHoverHold")
      vim.o.updatetime = math.min(vim.o.updatetime, 700)
      vim.api.nvim_create_autocmd("CursorHold", {
        group = vim.api.nvim_create_augroup("LspHoverHoldQuiet", { clear = true }),
        callback = function()
          if not (H and H.enabled) then
            return
          end
          if
            (H.last_win and vim.api.nvim_win_is_valid(H.last_win))
            or (H.freeze_until and H.freeze_until > (vim.uv.now() or 0))
          then
            return
          end
          hover_quiet({ border = BORDER, max_width = 65, max_height = 12, truncate = H.truncate, max_lines = 12 })
        end,
      })

      -- Cuộn trong popup hover
      local function hover_scroll(dir)
        local w, b = H.last_win, H.last_buf
        if not (w and b and vim.api.nvim_win_is_valid(w) and vim.api.nvim_buf_is_loaded(b)) then
          return
        end
        H.freeze_until = (vim.uv.now() or 0) + 700 -- đóng băng để không tự render lại
        local step = math.max(1, math.floor(vim.api.nvim_win_get_height(w) / 2)) * (dir < 0 and -1 or 1)
        vim.api.nvim_win_call(w, function()
          local cur = vim.api.nvim_win_get_cursor(w)
          local maxl = vim.api.nvim_buf_line_count(b)
          local newline = math.min(maxl, math.max(1, cur[1] + step))
          vim.api.nvim_win_set_cursor(w, { newline, 0 })
          vim.cmd("normal! zt")
        end)
      end

      vim.keymap.set("n", "<C-n>", function()
        hover_scroll(1)
      end, { desc = "Hover scroll down" })
      vim.keymap.set("n", "<C-p>", function()
        hover_scroll(-1)
      end, { desc = "Hover scroll up" })
      vim.keymap.set("n", "<leader>qh", function()
        if H.last_win and vim.api.nvim_win_is_valid(H.last_win) then
          pcall(vim.api.nvim_win_close, H.last_win, true)
        end
      end, { desc = "Close Hover popup" })

      -- Màu popup
      pcall(vim.api.nvim_set_hl, 0, "FloatBorder", { link = "WinSeparator" })
      pcall(vim.api.nvim_set_hl, 0, "NormalFloat", { link = "Normal" })

      ----------------------------------------------------------------------
      -- Inlay hints: enable/toggle an toàn API (v0.10/v0.11/v0.12)
      ----------------------------------------------------------------------
      local function inlay_enable(enabled, bufnr)
        local ih = vim.lsp.inlay_hint
        if not (ih and ih.enable) then
          return
        end
        if not pcall(ih.enable, enabled, bufnr and { bufnr = bufnr } or nil) and bufnr then
          pcall(ih.enable, bufnr, enabled)
        end
      end
      local function inlay_is_enabled(bufnr)
        local ih = vim.lsp.inlay_hint
        if not (ih and ih.is_enabled) then
          return false
        end
        local ok, v = pcall(ih.is_enabled, bufnr and { bufnr = bufnr } or nil)
        return ok and v == true
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspInlayHintsAuto", { clear = true }),
        callback = function(args)
          inlay_enable(true, args.buf)
        end,
      })

      _G.__LSP_UI__ = { inlay_enable = inlay_enable, inlay_is_enabled = inlay_is_enabled }
    end,
    keys = {
      {
        "<leader>uh",
        function()
          local h = rawget(_G, "__LSP_UI__")
          local buf = vim.api.nvim_get_current_buf()
          if h then
            h.inlay_enable(not h.inlay_is_enabled(buf), buf)
          end
        end,
        desc = "Toggle Inlay Hints",
      },
      {
        "<leader>uD",
        function()
          local vt = (vim.diagnostic.config() or {}).virtual_text
          local is_on = (vt == nil) or (vt == true) or (type(vt) == "table")
          if is_on then
            vim.diagnostic.config({ virtual_text = false })
            vim.notify("Diagnostics virtual_text: OFF")
          else
            vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "●", source = "if_many" } })
            vim.notify("Diagnostics virtual_text: ON")
          end
        end,
        desc = "Toggle Diagnostic Virtual Text",
      },
    },
  },

  -- 2) Completion: cửa sổ có viền, định dạng gọn, hiệu năng
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Menu gọn, không scrollbar, tách màu rõ
      opts.window = {
        completion = {
          scrollbar = false,
          winhighlight = table.concat({
            "Normal:Pmenu", -- nền menu
            "FloatBorder:CmpBorder", -- để sau dùng chung màu border
            "CursorLine:PmenuSel", -- dòng chọn
            "Search:None",
          }, ","),
        },
        documentation = { border = "rounded", winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder" },
      }

      -- Làm màu dễ thấy (TokyoNight)
      pcall(vim.api.nvim_set_hl, 0, "FloatBorder", { fg = "#7aa2f7", bg = "NONE" })
      pcall(vim.api.nvim_set_hl, 0, "CmpBorder", { link = "FloatBorder" })
      pcall(vim.api.nvim_set_hl, 0, "Pmenu", { link = "NormalFloat" })
      pcall(vim.api.nvim_set_hl, 0, "PmenuSel", { link = "Visual" })

      -- Gọn nội dung + hiệu năng
      opts.experimental = vim.tbl_deep_extend("force", opts.experimental or {}, {
        ghost_text = { hl_group = "Comment" },
      })
      opts.formatting = {
        fields = { "kind", "abbr" },
        format = function(_, item)
          local icons = (require("lazyvim.config").icons or {}).kinds or {}
          item.kind = (icons[item.kind] or "") .. " " .. item.kind
          local abbr = item.abbr:gsub("%s*%([^)]*%)", "")
          if #abbr > 46 then
            abbr = abbr:sub(1, 43) .. "…"
          end
          item.abbr, item.menu = abbr, ""
          return item
        end,
      }
      opts.performance = vim.tbl_deep_extend("force", opts.performance or {}, {
        debounce = 20,
        throttle = 30,
        fetching_timeout = 120,
      })

      -- Nếu đang dùng hiệu ứng mờ làm viền “biến mất”, tắt thử:
      vim.o.pumblend = 0

      return opts
    end,
  },

  -- 3) Noice: viền doc, tắt progress, lọc spam/jdtls/hover trống
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.lsp = vim.tbl_deep_extend("force", opts.lsp or {}, { progress = { enabled = false } })
      opts.presets = vim.tbl_deep_extend("force", opts.presets or {}, { lsp_doc_border = true })
      opts.routes = vim.list_extend(opts.routes or {}, {
        {
          filter = {
            any = {
              { event = "notify", find = "Classpath is incomplete" },
              { event = "notify", find = "No delegateCommandHandler" },
              { event = "lsp", kind = "progress", find = "Building" },
              { event = "lsp", kind = "message", find = "Building workspace" },
              { event = "msg_show", find = "jdtls" },
              { event = "notify", find = "No hover information" },
              {
                event = "notify",
                find = "method textDocument/hover is not supported by any of the servers registered for the current buffer",
              },
              { event = "notify", find = "No information available" },
            },
          },
          opts = { skip = true },
        },
      })
      return opts
    end,
  },

  -- 4) Fidget: progress gọn + viền tròn
  {
    "j-hui/fidget.nvim",
    opts = { progress = { suppress_on_insert = true }, notification = { window = { border = "rounded" } } },
  },

  -- 5) Trouble: bảng lỗi dùng diagnostic signs, phím tắt gọn
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>", desc = "Diagnostics (Trouble)" } },
    opts = { use_diagnostic_signs = true },
  },
}
