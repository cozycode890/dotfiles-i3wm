return {
  "NvChad/nvim-colorizer.lua",
  -- Tải plugin khi mở một file (thay vì lúc khởi động)
  event = "BufRead",
  config = function()
    -- Kích hoạt plugin với cấu hình mặc định
    require("colorizer").setup()
  end,
}
