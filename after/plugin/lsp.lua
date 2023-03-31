local lspconfig = require 'lspconfig'

local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }
    --vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    --vim.keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end, opts)
    --vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
    --vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts) -- Simulates hovering in VSCode
    --vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    --vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
    --vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    --vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    --vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    --vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    --vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", opts)
    -- Autoformatter on save
    --vim.cmd([[
    --    augroup formatting
    --        autocmd! * <buffer>
    --        autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
    --    augroup END
    --]])
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

local servers = {}

-- takes the above server block to configure individual language servers
mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
}

-- language server is like a separate binary that runs
-- here is the stuff we want to pass through to the language server
mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }
    end,
    ['lua_ls'] = function()
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }
    end,
    ['groovyls'] = function()
      lspconfig.groovyls.setup {
        capabilities = capabilities,
        on_attach = on_attach,
        root_dir = lspconfig.util.root_pattern({"gradlew", "mvnw", ".git"}),
        settings = {
        },
      }
    end,
    -- Example of manual configuration done for a specific language
    -- It's better to do this than use the automatic one above when possible
    --['vuels'] = function()
    --    lspconfig.vuels.setup {
    --        capabilities = capabilities,
    --        on_attach = on_attach,
    --        root_dir = function(fname)
    --            local primary = lspconfig.util.find_git_ancestor(fname)
    --            local fallback = lspconfig.util.root_pattern("package.json", "vue.config.js")
    --            return primary or fallback
    --        end,
    --    }
    --end,
}

require('fidget').setup()

