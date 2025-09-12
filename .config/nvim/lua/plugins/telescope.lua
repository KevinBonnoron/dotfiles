return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<C-F>", ":Telescope live_grep<CR>", { desc = "Search in files" })
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
          }
        }
      }
    end
  }
}
