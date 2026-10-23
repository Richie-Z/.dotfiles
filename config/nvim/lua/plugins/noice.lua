---@type LazySpec
return {
  "folke/noice.nvim",
  opts = function(_, opts)
    local utils = require "astrocore"
    return utils.extend_tbl(opts, {
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
      },
      lsp = {
        progress = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = false,
      },
    })
  end,
}
