return {
{
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
      cmd = "Telescope",
      keys = {
	      {'<leader>ff', mode = "n", require("telescope.builtin").find_files,  desc = 'Telescope find files' },
	      {'<leader>fg', mode = "n", require("telescope.builtin").live_grep,  desc = 'Telescope live grep' },
	      {'<leader>fb', mode = "n", require("telescope.builtin").buffers,  desc = 'Telescope buffers' },
		{'<leader>fh', mode = "n", require("telescope.builtin").help_tags,  desc = 'Telescope help tags' },
      }
    },
{
  "nvim-telescope/telescope-fzf-native.nvim",
  build = (build_cmd ~= "cmake") and "make"
    or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  enabled = build_cmd ~= nil,
  config = function(plugin)
    vim.on_load("telescope.nvim", function()
      local ok, err = pcall(require("telescope").load_extension, "fzf")
      if not ok then
        local lib = plugin.dir .. "/build/libfzf." .. (vim.is_win() and "dll" or "so")
        if not vim.uv.fs_stat(lib) then
          vim.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
          require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
            vim.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
          end)
        else
          vim.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
        end
      end
    end)
  end,
}
}
