return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      -- 1) Dùng Ruff formatter (nhanh, đồng bộ rule lint)
      -- python = { "ruff_format", "ruff_fix" },
      -- 2) Hoặc Black + isort của Ruff (import order)
      python = { "black", "ruff_organize_imports" },
    },
  },
}
