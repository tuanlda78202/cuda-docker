return {
  'neovim/nvim-lspconfig',
  config = function()
    vim.diagnostic.config({
      update_in_insert = true
    })
    require('lspconfig').clangd.setup {on_attach = require("custom.utils.lsp")}

  end
}
