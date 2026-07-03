return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  -- Completion-driven bracket insertion is handled by blink.cmp's
  -- `completion.accept.auto_brackets`, so no cmp integration is needed here.
  opts = {},
}
