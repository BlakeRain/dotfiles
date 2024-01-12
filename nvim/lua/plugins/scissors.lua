-- Scissors: Snippet management
-- https://github.com/chrisgrieser/nvim-scissors
return {
  "chrisgrieser/nvim-scissors",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    snippetDir = "~/cs/dotfiles/nvim/snippets"
  }
}
