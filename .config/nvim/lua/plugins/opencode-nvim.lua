return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Needed for :toggle() and for the nice input/picker UI
      { "folke/snacks.nvim", opts = { input = {}, picker = {} } },
    },
    config = function()
      -- Optional: plugin options (see lua/opencode/config.lua in the repo)
      vim.g.opencode_opts = {}
      -- Neovim should auto-reload files that OpenCode edits
      vim.opt.autoread = true

      -- Keymaps (replace your old `.open()` call with these)
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask about this" })

      vim.keymap.set({ "n", "x" }, "<leader>o+", function()
        require("opencode").prompt("@this")
      end, { desc = "Add this" })

      vim.keymap.set("n", "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select prompt" })

      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle embedded OpenCode" })

      vim.keymap.set("n", "<leader>oc", function()
        require("opencode").command()
      end, { desc = "OpenCode command" })
    end,
  },
}
