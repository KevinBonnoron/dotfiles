return {
  "numToStr/Comment.nvim",
  config = function()
    local commentApi = require('Comment.api')
    require('Comment').setup()
    vim.keymap.set("n", "<C-/>", function() commentApi.toggle.linewise.current() end,{ desc = "Toggle comment line" })
    vim.keymap.set("v", "<C-/>", function() commentApi.toggle.linewise(vim.fn.visualmode()) end, { desc = "Toggle comment selection" })
  end,
}
