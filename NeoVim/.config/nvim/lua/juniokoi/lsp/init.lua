local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("juniokoi.lsp.lsp-installer")
require("juniokoi.lsp.handlers").setup()
