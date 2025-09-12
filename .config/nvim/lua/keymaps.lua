-- File editor
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("i", "<A-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("i", "<A-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

vim.keymap.set("n", "<C-f>", "/", { desc = "Search in file" })
vim.keymap.set("i", "<C-f>", "<Esc>/", { desc = "Search in file" })

vim.keymap.set("n", "<A-S-Down>", ":copy .<CR>", { desc = "Duplicate line down" })
vim.keymap.set("i", "<A-S-Down>", "<Esc>:copy .<CR>gi", { desc = "Duplicate line down" })
vim.keymap.set("v", "<A-S-Down>", ":copy '><CR>gv", { desc = "Duplicate selection down" })

vim.keymap.set("n", "<F5>", function()
  vim.api.nvim_open_win(0, true, {
    width = 120,
    height = 10,
    win = 0,
    row = 20,
    col = 20,
    --external = true,
    relative = 'win',
  })
end)
