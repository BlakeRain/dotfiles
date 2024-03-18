-- Help with management of crates.io dependencies.
-- https://github.com/Saecki/crates.nvim

return {
  "saecki/crates.nvim",
  tag = "stable",
  event = { "BufRead Cargo.toml" },
  config = function()
    require("crates").setup()
  end
}
