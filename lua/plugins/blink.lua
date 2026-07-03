return {
  "saghen/blink.cmp",
  -- Pin to a release so the prebuilt Rust fuzzy-matching binary is downloaded
  -- (no local Rust toolchain required).
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  -- Snippet library, loaded through blink's built-in snippet source.
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    -- `enter` preset: <CR> accepts the (pre)selected item, <C-Space> toggles
    -- the menu / documentation, <C-p>/<C-n> move the selection. Mirrors the
    -- previous nvim-cmp mappings.
    keymap = { preset = "enter" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },
      -- Insert () after functions/methods on accept — replaces the old
      -- nvim-autopairs + cmp `confirm_done` integration.
      accept = { auto_brackets = { enabled = true } },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        -- Preserve the old per-source keyword-length thresholds.
        snippets = { min_keyword_length = 2 },
        buffer = { min_keyword_length = 3 },
      },
    },
    signature = { enabled = true },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
