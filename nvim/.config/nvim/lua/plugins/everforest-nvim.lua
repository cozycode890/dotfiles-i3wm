local colorscheme = require("lazyvim.plugins.colorscheme")
return {
  { "neanias/everforest-nvim" },

  -- Configure LazyVim to load everforest
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  },
}
