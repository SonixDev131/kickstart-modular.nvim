return -- lazy.nvim
{
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    require('snacks').setup {
      lazygit = {},
      indent = {},
      quickfile = {},
      bigfile = {},
      scope = {},
    }

    -- LazyGit
    -- Helper function to get git root directory
    local function get_git_root()
      local git_root = vim.fs.find('.git', { path = vim.fn.getcwd(), upward = true })[1]
      return git_root and vim.fn.fnamemodify(git_root, ':h') or vim.fn.getcwd()
    end

    vim.keymap.set('n', '<leader>gg', function()
      Snacks.lazygit { cwd = get_git_root() }
    end, { desc = 'Lazy[G]it (Root Dir)' })

    vim.keymap.set('n', '<leader>gG', function()
      Snacks.lazygit()
    end, { desc = 'Lazy[^G]it (cwd)' })

    vim.keymap.set('n', '<leader>gl', function()
      Snacks.picker.git_log { cwd = get_git_root() }
    end, { desc = '[G]it [L]og' })

    vim.keymap.set('n', '<leader>gL', function()
      Snacks.picker.git_log()
    end, { desc = '[G]it [^L]og (cwd)' })

    vim.keymap.set('n', '<leader>db', function()
      Snacks.bufdelete()
    end, { desc = '[D]elete a [B]uffer' })

    --Bufdelete
    vim.keymap.set('n', '<leader>dB', function()
      Snacks.bufdelete.other()
    end, { desc = '[D]elete all [^B]uffers except the current one' })
  end,
}
