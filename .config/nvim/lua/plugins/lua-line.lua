return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_w = { "encoding", "fileformat", "filetype" },
        lualine_x = { "lsp_status" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
