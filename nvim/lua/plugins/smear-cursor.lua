return {
  "sphamba/smear-cursor.nvim",
  keys = {
    { "<leader>eS", function() require("smear_cursor").toggle() end, desc = "Toggle smear cursor" }
  }
}
