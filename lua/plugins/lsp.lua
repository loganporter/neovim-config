-- Adapted from a combo of
-- https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html
-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/lazy/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "saghen/blink.cmp",
    "j-hui/fidget.nvim",
  },
  config = function()
    -- blink.cmp advertises the extra completion capabilities to each server
    -- (merged on top of Neovim's defaults).
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    require("fidget").setup({})
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",
        "lua_ls",
        "ruff",
        "rust_analyzer",
        "eslint",
        "graphql",
        "biome",
      },
      -- We enable servers ourselves below via vim.lsp.enable.
      automatic_enable = false,
    })

    -- Configure diagnostics
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        focusable = true,
        style = "minimal",
        border = "rounded",
      }
    })

    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover({
        border = {
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
          { " ", "NormalFloat" },
        },
      })
    end, { desc = 'Hover' })


    -- Native LSP config (nvim 0.11+). nvim-lspconfig ships the base server
    -- definitions (cmd/root markers/filetypes) under its `lsp/` runtime dir;
    -- vim.lsp.config() layers our overrides on top and vim.lsp.enable() starts them.

    -- Defaults applied to every server.
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim", "love" },
          },
          workspace = {
            library = {
              vim.env.VIMRUNTIME,
            },
          },
        },
      },
    })

    vim.lsp.config("graphql", {
      filetypes = { "graphql", "gql", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    })

    -- Biome fix-all on save is handled by conform.nvim (biome-check), so we
    -- don't wire up an LSP autocmd for it here.

    -- ESLint provides a buffer-local LspEslintFixAll command via its base
    -- on_attach; run it on save without overriding that on_attach. This only
    -- fires in buffers ESLint actually attached to, which (see below) means
    -- buffers in a real ESLint project.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "eslint" then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            command = "LspEslintFixAll",
          })
        end
      end,
    })

    -- Both Biome and ESLint are enabled unconditionally: lspconfig's base
    -- definitions set `workspace_required = true` and a `root_dir` that
    -- searches upward from *the buffer's own file* for that tool's config,
    -- declining to attach when there isn't one. So each server attaches only
    -- in the projects that actually use it, and a Biome package and an ESLint
    -- package can be open in the same session.
    --
    -- (Previously this picked one of the two once at startup based on the cwd,
    -- which meant launching nvim from a monorepo root or from ~ locked the
    -- whole session to the wrong server.)
    vim.lsp.enable({
      "ts_ls",
      "lua_ls",
      "ruff",
      "rust_analyzer",
      "graphql",
      "biome",
      "eslint",
    })
  end
}
