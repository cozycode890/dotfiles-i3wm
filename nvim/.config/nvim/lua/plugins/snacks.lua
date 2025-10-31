-- ~/.config/nvim/lua/plugins/snacks-dashboard-order.lua
return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}

      local function S()
        return require("snacks")
      end

      opts.dashboard.preset.keys = {
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
            S().session.load()
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
      }

      return opts
    end,
  },
}
