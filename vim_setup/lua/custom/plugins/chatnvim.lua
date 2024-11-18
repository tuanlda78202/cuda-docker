return {
  "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
    local home = vim.fn.expand("$HOME")
      require("chatgpt").setup(
      {
  openai_params = {
    model = "Llama3-70b-8192"  -- Overriding the model name
  },
  openai_edit_params = {
    model = "Llama3-70b-8192"  -- Overriding the model name
  },
    api_key_cmd = "cat " .. home .. "/openai_key"
}
    )
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    }
}
