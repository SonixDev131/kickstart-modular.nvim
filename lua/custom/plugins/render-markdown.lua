return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  config = function()
    require('render-markdown').setup {
      file_types = { 'markdown', 'codecompanion' },
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false, -- Turn off in the status column
      },
    }
    vim.treesitter.language.register('markdown', 'codecompanion')
  end,
}
