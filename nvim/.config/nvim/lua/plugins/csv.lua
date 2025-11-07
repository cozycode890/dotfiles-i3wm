-- lua/plugins/csv.lua
return {
  { "mechatroner/rainbow_csv", ft = { "csv", "tsv" } },
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    opts = {}, -- để mặc định cũng được
    keys = {
      { "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "CSV: Toggle view" },
    },
  },
}
