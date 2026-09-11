vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
  print("Last reloaded " .. os.clock())
end)
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")
vim.keymap.set("x", "p", [["_dP]])                 -- Puts without filling "" register
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]) -- Yanks into "+ register
vim.keymap.set("n", "<leader>Y", [["+Y]])

local function copy_file_path(modifier)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("Buffer has no file", vim.log.levels.WARN)
    return
  end

  path = vim.fn.fnamemodify(path, modifier)
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. path)
end

vim.keymap.set("n", "<leader>fr", function()
  copy_file_path(":.")
end, { desc = "Copy relative file path" })

vim.keymap.set("n", "<leader>fa", function()
  copy_file_path(":p")
end, { desc = "Copy absolute file path" })

vim.keymap.set("t", "<c-w>j", "<c-\\><c-n><c-w>j")
vim.keymap.set("t", "<c-w>k", "<c-\\><c-n><c-w>k")
vim.keymap.set("t", "<c-w>h", "<c-\\><c-n><c-w>h")
vim.keymap.set("t", "<c-w>l", "<c-\\><c-n><c-w>l")
vim.keymap.set("n", "<leader>dd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)
