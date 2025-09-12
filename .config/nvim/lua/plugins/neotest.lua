return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-jest")({
            jestCommand = "yarn test --",
            jestConfigFile = "jest.config.ts",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end
          })
        }
      })

      vim.keymap.set("n", "<F5>", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run current test" })
    end
  },
  {
    "nvim-neotest/neotest-jest",
    dependencies = { "nvim-neotest/neotest" },
 }
}
