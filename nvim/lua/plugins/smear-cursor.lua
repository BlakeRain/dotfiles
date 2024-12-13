return {
  "sphamba/smear-cursor.nvim",
  keys = {
    { "<leader>es", function() require("smear_cursor").toggle() end, desc = "Toggle smear cursor" }
  }
}
