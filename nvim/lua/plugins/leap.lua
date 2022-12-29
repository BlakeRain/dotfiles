return {
  {
    -- Leap for visual word jumping (reboot of Lightspeed)
    -- https://github.com/ggandor/leap.nvim
    'ggandor/leap.nvim',
    event = "VeryLazy",
    config = function()
      require("leap").add_default_mappings()
    end
  },
  {
    -- Spooky leap actions
    -- https://github.com/ggandor/leap-spooky.nvim
    'ggandor/leap-spooky.nvim',
    event = "VeryLazy",
    config = function()
      require("leap-spooky").setup({})
    end
  }
}
