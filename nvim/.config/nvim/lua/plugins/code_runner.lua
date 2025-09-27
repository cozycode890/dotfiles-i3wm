-- lua/plugins/code-runner.lua
return {
  {
    "CRAG666/code_runner.nvim",
    cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
    keys = {
      { "<leader>rr", "<cmd>RunCode<CR>", mode = "n", silent = false, desc = "Run Code" },
      { "<leader>rf", "<cmd>RunFile<CR>", mode = "n", silent = false, desc = "Run File" },
      { "<leader>rft", "<cmd>RunFile tab<CR>", mode = "n", silent = false, desc = "Run File (new tab)" },
      { "<leader>rp", "<cmd>RunProject<CR>", mode = "n", silent = false, desc = "Run Project" },
      { "<leader>rc", "<cmd>RunClose<CR>", mode = "n", silent = false, desc = "Run Close" },
      { "<leader>crf", "<cmd>CRFiletype<CR>", mode = "n", silent = false, desc = "CodeRunner: Filetype" },
      { "<leader>crp", "<cmd>CRProjects<CR>", mode = "n", silent = false, desc = "CodeRunner: Projects" },
    },
    opts = {
      filetype = {
        java = {
          "cd $dir &&",
          "javac $fileName &&",
          "java $fileNameWithoutExt",
        },
        python = "python3 -u",
        typescript = "deno run",
        rust = {
          "cd $dir &&",
          "rustc $fileName &&",
          "$dir/$fileNameWithoutExt",
        },
        c = function(...)
          local c_base = {
            "cd $dir &&",
            "gcc $fileName -o",
            "/tmp/$fileNameWithoutExt",
          }
          local c_exec = {
            "&& /tmp/$fileNameWithoutExt &&",
            "rm /tmp/$fileNameWithoutExt",
          }
          vim.ui.input({ prompt = "Add more args:" }, function(input)
            c_base[4] = input
            require("code_runner.commands").run_from_fn(vim.list_extend(c_base, c_exec))
          end)
        end,
      },
    },
    config = function(_, opts)
      require("code_runner").setup(opts)
    end,
  },
}
