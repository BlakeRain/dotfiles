-- Set the comment string for roff
vim.bo.commentstring = ".\\\" %s"

require("nvim-surround").buffer_setup({
  surrounds = {
    ['I'] = {
      add = { "\\fI", "\\fP" },
      find = "\\fI.-\\fP",
      delete = "^(\\fI)().-(\\fP)()$",
    },
    ['B'] = {
      add = { "\\fB", "\\fP" },
      find = "\\fB.-\\fP",
      delete = "^(\\fB)().-(\\fP)()$",
    },
    ['C'] = {
      add = { "\\fC", "\\fP" },
      find = "\\fC.-\\fP",
      delete = "^(\\fC)().-(\\fP)()$",
    }
  }
})
