-- lua/plugins/mini-animate.lua
return {
  { import = "lazyvim.plugins.extras.ui.mini-animate" },
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    opts = function(_, opts)
      local animate = require("mini.animate")

      opts.open = { enable = false }
      opts.close = { enable = false }
      opts.resize = { enable = false }
      opts.cursor = { enable = false }

      opts.scroll = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 140, unit = "total" }),
        subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 }),
      }
      return opts
    end,
  },
}
