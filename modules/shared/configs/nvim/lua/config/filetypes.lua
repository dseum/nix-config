vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
  },
})
vim.filetype.add({
  filename = {
    Caddyfile = "caddyfile",
  },
})
vim.filetype.add({
  pattern = {
    [".env.*"] = "sh",
  },
})
