-- Adapted from a combo of
-- https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html
-- https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/lazy/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "j-hui/fidget.nvim",
  },
  config = function()
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities()
    )

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
      -- We enable servers ourselves below via vim.lsp.enable so the
      -- Biome/ESLint fallback stays under our control.
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
        focusable = false,
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
    -- on_attach; run it on save without overriding that on_attach.
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

    -- Prefer Biome when the project defines it, otherwise fall back to ESLint.
    local uv = vim.uv or vim.loop
    local cwd = vim.fn.getcwd()
    local web_linter = (uv.fs_stat(cwd .. "/biome.json") or uv.fs_stat(cwd .. "/biome.jsonc"))
        and "biome"
        or "eslint"

    vim.lsp.enable({
      "ts_ls",
      "lua_ls",
      "ruff",
      "rust_analyzer",
      "graphql",
      web_linter,
    })

    local cmp = require('cmp')
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    -- this is the function that loads the extra snippets to luasnip
    -- from rafamadriz/friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
      sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lint' },
        { name = 'luasnip',  keyword_length = 2 },
        { name = 'buffer',   keyword_length = 3 },
      },
      mapping = cmp.mapping.preset.insert({
        -- ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        -- ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
    })
  end
}
