return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts = opts or {}
    opts.lsp = vim.tbl_deep_extend("force", opts.lsp or {}, {
      progress = { enabled = false }, -- tắt thanh tiến độ LSP (jdtls spam nhiều)
    })

    -- Thêm các route lọc thông báo ồn ào
    opts.routes = vim.list_extend(opts.routes or {}, {
      {
        -- Ẩn các notify/msg phổ biến từ jdtls
        filter = {
          any = {
            { event = "notify", find = "Classpath is incomplete" },
            { event = "notify", find = "No delegateCommandHandler" },
            { event = "lsp", kind = "progress", find = "Building" },
            { event = "lsp", kind = "message", find = "Building workspace" },
            { event = "msg_show", find = "jdtls" },
          },
        },
        opts = { skip = true },
      },
    })

    return opts
  end,
}
