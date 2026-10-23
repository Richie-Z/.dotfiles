---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          "██████╗ ██████╗ ███████╗ █████╗ ██████╗ ██╗    ██╗██╗   ██╗███╗   ███╗",
          "██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗██║    ██║╚██╗ ██╔╝████╗ ████║",
          "██║  ██║██████╔╝█████╗  ███████║██║  ██║██║ █╗ ██║ ╚████╔╝ ██╔████╔██║",
          "██║  ██║██╔══██╗██╔══╝  ██╔══██║██║  ██║██║███╗██║  ╚██╔╝  ██║╚██╔╝██║",
          "██████╔╝██║  ██║███████╗██║  ██║██████╔╝╚███╔███╔╝   ██║   ██║ ╚═╝ ██║",
          "╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚══╝╚══╝    ╚═╝   ╚═╝     ╚═╝",
          "",
          "We are prisoners of the present, forever transitioning between our inaccessible past and our unknowable future",
          ">>> Neil deGrasse Tyson <<<",
        }, "\n"),
      },
    },
  },
}
