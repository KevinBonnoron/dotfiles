return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "json", "html", "css", "typescript", "markdown", "vimdoc" },
      highlight = {
        enable = true,
        disable = { "help" }
      },
      indent = { enable = true },
    })
  end,
}
