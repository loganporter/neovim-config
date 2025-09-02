return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  opts = {
    enabled = true,
    message_template = " <summary> • <date> • <author>",
    date_format = "%r",
    gitblame_highlight_group = "Comment",
    delay = 250,
  },
}
