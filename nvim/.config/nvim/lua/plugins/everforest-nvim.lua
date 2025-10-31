return {
  -- Theme plugin (Lua port)
  {
    "neanias/everforest-nvim",
    lazy = false, -- load sớm để set colorscheme
    priority = 1000, -- ưu tiên cao để áp theme trước plugin khác
    opts = function()
      -- Mặc định: transparent = 3 ; Khi chạy trong Neovide: = 0
      local level = 3
      if vim.g.neovide then
        level = 0
      end
      return {
        transparent_background_level = level,
      }
    end,
    config = function(_, opts)
      require("everforest").setup(opts)
      -- đảm bảo apply theme
      vim.cmd.colorscheme("everforest")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
