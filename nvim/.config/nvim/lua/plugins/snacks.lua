return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fg",
        function()
          local Snacks = require("snacks")
          -- Lấy thư mục hiện tại: dir của buffer nếu có, else cwd
          local bufpath = vim.api.nvim_buf_get_name(0)
          local curdir = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":p:h")) or (vim.uv.cwd() or vim.fn.getcwd())
          -- Lấy thư mục cha (":h:h" = lấy dir rồi lại lấy dir cha)
          local parent = vim.fn.fnamemodify(curdir, ":p:h")
          -- Nếu đang ở root thì parent = root
          if parent == "" then
            parent = curdir
          end

          Snacks.picker.grep({
            cmd = "rg",
            cwd = parent,
            args = {
              "--hidden",
              "--glob",
              "!**/.git/**",
              -- thêm tuỳ chọn loại trừ nếu muốn:
              -- "--glob", "!**/node_modules/**",
              -- "--glob", "!**/dist/**",
            },
          })
        end,
        desc = "Find Text (parent of current dir)",
        mode = "n",
      },
      {
        "<leader>E",
        function()
          require("snacks").explorer() -- để Snacks tự chọn root theo vim.g.root_spec
        end,
        desc = "Explorer (project root by spec)",
        mode = "n",
      },
      {
        "<c-/>",
        function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":p:h")) or vim.uv.cwd()
          Snacks.terminal(nil, { cwd = dir })
        end,
        desc = "Terminal (buffer dir)",
      },
      {
        "<leader>e",
        function()
          local Snacks = require("snacks")
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir = (bufpath ~= "" and vim.fn.fnamemodify(bufpath, ":p:h")) or vim.uv.cwd()
          Snacks.explorer({ cwd = dir })
        end,
        desc = "Explorer (buffer's directory)",
        mode = "n",
      },
    },
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.dashboard = opts.dashboard or {}

      local function S()
        return require("snacks")
      end

      opts.dashboard.preset.keys = vim.tbl_deep_extend("force", {
        -- 1) Find File (giống mặc định về vị trí, hành vi theo bạn)
        {
          icon = " ",
          key = "f",
          desc = "Find File",
          action = function()
            S().picker.files({
              cmd = "fd",
              args = { "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
            })
          end,
        },
        -- 2) New File
        {
          icon = " ",
          key = "n",
          desc = "New File",
          action = function()
            vim.cmd("enew")
          end,
        },
        -- 3) Projects
        {
          icon = " ",
          key = "p",
          desc = "Projects",
          action = function()
            S().picker.projects()
          end,
        },
        -- 4) Find Text (giữ vị trí, hành vi theo bạn)
        {
          icon = " ",
          key = "g",
          desc = "Find Text",
          action = function()
            S().picker.grep({
              cmd = "rg",
              args = { "--hidden", "--glob", "!**/.git/**" },
            })
          end,
        },
        -- 5) Recent Files
        {
          icon = " ",
          key = "r",
          desc = "Recent Files",
          action = function()
            S().picker.recent()
          end,
        },
        -- 6) Config
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = function()
            S().picker.files({
              cmd = "fd",
              args = { "--type", "f", "--hidden", "--follow" },
              cwd = vim.fn.stdpath("config"),
            })
          end,
        },

        -- 7) Restore Session
        {
          icon = " ",
          key = "s",
          desc = "Restore Session",
          action = function()
            local ok_persist, persistence = pcall(require, "persistence")
            if ok_persist then
              persistence.load()
            else
              vim.notify("Chưa có snacks.session và cũng không tìm thấy persistence.nvim", vim.log.levels.WARN)
            end
          end,
        },

        -- 8) Lazy Extras
        {
          icon = " ",
          key = "x",
          desc = "Lazy Extras",
          action = function()
            vim.cmd("LazyExtras")
          end,
        },
        -- 9) Lazy
        {
          icon = "󰒲 ",
          key = "l",
          desc = "Lazy",
          action = function()
            vim.cmd("Lazy")
          end,
        },
        -- 10) Quit
        {
          icon = " ",
          key = "q",
          desc = "Quit",
          action = function()
            vim.cmd("qall")
          end,
        },
      }, opts.dashboard.preset or {})

      opts.terminal = vim.tbl_deep_extend("force", {
        start_insert = true,
        win = {
          position = "float", -- nổi
          border = "rounded",
          width = 0.9, -- 90% chiều ngang màn hình
          height = 0.9, -- 90% chiều dọc màn hình
        },
      }, opts.terminal or {})

      return opts
    end,
  },
}
