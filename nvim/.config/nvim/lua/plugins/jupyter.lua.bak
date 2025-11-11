-- Molten + Jupytext + image.nvim (tinh gọn)
return {
  -- Molten
  {
    "benlubas/molten-nvim",
    ft = { "python", "markdown", "quarto", "ipynb", "r", "rmd", "rmarkdown" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_wrap_output = false
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = function()
      local function insert_percent_marker(delta)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local pos = math.max(0, row + (delta or 0))
        vim.api.nvim_buf_set_lines(0, pos, pos, true, { "# %%" })
      end

      local function select_inside_cell()
        local api, buf = vim.api, 0
        local row = api.nvim_win_get_cursor(0)[1]
        local lines = api.nvim_buf_get_lines(buf, 0, -1, true)
        local n = #lines
        local function is_pct(i)
          local s = lines[i] or ""
          return s:match("^%s*#%s*%%%%") or s:match("^%s*#%%%%")
        end
        local function is_fence(i)
          local s = lines[i] or ""
          return s:match("^%s*```")
        end
        local mode
        for k = row, math.max(1, row - 50), -1 do
          if is_pct(k) then
            mode = "percent"
            break
          end
          if is_fence(k) then
            mode = "fence"
            break
          end
        end
        if not mode then
          for k = row, math.min(n, row + 50) do
            if is_pct(k) then
              mode = "percent"
              break
            end
            if is_fence(k) then
              mode = "fence"
              break
            end
          end
        end
        local s, e
        if mode == "percent" then
          local up = row
          while up >= 1 and not is_pct(up) do
            up = up - 1
          end
          local dn = row
          while dn <= n and not is_pct(dn) do
            dn = dn + 1
          end
          s = (up >= 1 and is_pct(up)) and (up + 1) or 1
          e = (dn <= n and is_pct(dn)) and (dn - 1) or n
        elseif mode == "fence" then
          local up = row
          while up >= 1 and not is_fence(up) do
            up = up - 1
          end
          local dn = row
          while dn <= n and not is_fence(dn) do
            dn = dn + 1
          end
          s = (up >= 1 and is_fence(up)) and (up + 1) or 1
          e = (dn <= n and is_fence(dn)) and (dn - 1) or n
        else
          s, e = 1, n
        end
        if s > e then
          vim.notify("Cell trống!", vim.log.levels.WARN)
          return
        end
        vim.fn.setpos("'<", { 0, s, 1, 0 })
        vim.fn.setpos("'>", { 0, e, 999, 0 })
        vim.cmd("normal! gv")
      end

      return {
        -- kernel lifecycle
        { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten: Init Kernel" },
        { "<leader>mx", "<cmd>MoltenDeinit<cr>", desc = "Molten: Deinit Kernel" },
        { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten: Delete Output" },

        -- quick eval
        { "<leader>ml", ":MoltenEvaluateLine<cr>", desc = "Molten: Evaluate Line", mode = "n" },
        { "<leader>ml", ":<C-u>MoltenEvaluateVisual<CR>gv<Esc>", mode = "v", desc = "Molten: Evaluate Selection" },

        -- output
        { "<leader>mo", "<cmd>MoltenEnterOutput<cr>", desc = "Molten: Enter Output" },
        { "<leader>mO", "<cmd>MoltenToggleOutput<cr>", desc = "Molten: Toggle Output" },

        -- utils
        { "<leader>mI", "<cmd>MoltenInfo<cr>", desc = "Molten: Info" },
        { "<leader>mK", "<cmd>MoltenInterrupt<cr>", desc = "Molten: Interrupt Kernel" },
        { "<leader>mR", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten: Re-eval Cell" },

        -- cells
        { "]m", "<cmd>MoltenNextCell<cr>", desc = "Molten: Next Cell" },
        { "[m", "<cmd>MoltenPrevCell<cr>", desc = "Molten: Previous Cell" },
        {
          "<leader>mc",
          function()
            insert_percent_marker(0)
          end,
          desc = "Insert #%% below",
        },
        {
          "<leader>mC",
          function()
            insert_percent_marker(-1)
          end,
          desc = "Insert #%% above",
        },

        { "<leader>mb", "<cmd>MoltenOpenInBrowser<cr>", desc = "Molten: Open Last HTML" },
        { "<leader>mg", "<cmd>MoltenImagePopup<cr>", desc = "Molten: Popup Last Image" },

        -- motions
        { "<leader>mm", "<cmd>MoltenEvaluateOperator<cr>", desc = "Molten: Motion" },
        {
          "<C-CR>",
          function()
            vim.cmd("MoltenEvaluateOperator")
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ip", true, false, true), "n", false)
          end,
          mode = "n",
          desc = "Molten: Eval Paragraph",
        },

        -- select cell
        { "<leader>ms", select_inside_cell, desc = "Molten: Select Inside Cell", mode = "n" },
      }
    end,
  },

  -- Jupytext glue (đọc/sync ipynb ↔ percent script tự động)
  {
    "goerz/jupytext.nvim",
    opts = {},
    config = function()
      local function exists(p)
        return p and vim.uv.fs_stat(p) ~= nil
      end

      -- Mở *.ipynb dưới dạng auto:percent và nhảy sang .R/.py
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "*.ipynb",
        callback = function(args)
          local stem = args.file:gsub("%.ipynb$", "")
          local out_r, out_py = stem .. ".R", stem .. ".py"
          local cmd = { "jupytext", "--from=ipynb", "--to=auto:percent", args.file }
          local jid = vim.fn.jobstart(cmd, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_exit = function(_, code)
              if code == 0 then
                if exists(out_r) then
                  vim.cmd.edit(vim.fn.fnameescape(out_r))
                elseif exists(out_py) then
                  vim.cmd.edit(vim.fn.fnameescape(out_py))
                else
                  vim.notify("Converted, nhưng không thấy .R/.py (kiểm tra kernelspec)", vim.log.levels.WARN)
                end
              else
                vim.notify("jupytext failed — xem ~/.jupytext.toml và stderr", vim.log.levels.ERROR)
              end
            end,
          })
          if jid <= 0 then
            vim.notify("Không chạy được jupytext (jobstart)", vim.log.levels.ERROR)
          end
        end,
      })

      -- Sync khi lưu .py/.R hoặc .ipynb
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.py", "*.R", "*.ipynb" },
        callback = function()
          vim.fn.jobstart({ "jupytext", "--sync", vim.fn.expand("%:p") }, { detach = true })
        end,
      })
    end,
  },

  -- image.nvim (provider cho Molten)
  {
    "3rd/image.nvim",
    lazy = true,
    opts = { backend = "kitty", tmux_show_only_in_active_window = true },
  },
}
