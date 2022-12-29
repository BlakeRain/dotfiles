-- Swap objects interactively using Treesitter
-- https://github.com/mizlan/iswap.nvim
--
-- Basically this lets us use '<Leader>cs' to swap sibling treesitter objects, such as function arguments.

local M = {
  "mizlan/iswap.nvim",
  keys = {
    { "<leader>cs", "<cmd>ISwap<cr>", desc = "Swap items" },
    { "<leader>cS", "<cmd>ISwapWith<cr>", desc = "Swap current item" }
  }
}

function M.config()
  require("iswap").setup({
    -- The keys that will be used as a selection, in order
    -- ('asdfghjklqwertyuiopzxcvbnm' by default)
    keys = 'qwertyuiop',

    -- Grey out the rest of the text when making a selection
    -- (enabled by default)
    grey = 'disable',

    -- Highlight group for the sniping value (asdf etc.)
    -- default 'Search'
    hl_snipe = 'ErrorMsg',

    -- Highlight group for the visual selection of terms
    -- default 'Visual'
    hl_selection = 'WarningMsg',

    -- Highlight group for the greyed background
    -- default 'Comment'
    hl_grey = 'LineNr',

    -- Automatically swap with only two arguments
    -- default nil
    autoswap = true,

    -- Other default options you probably should not change:
    debug = nil,
    hl_grey_priority = '1000'
  })
end

return M
