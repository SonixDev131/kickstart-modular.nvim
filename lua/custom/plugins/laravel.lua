return {
  'adalessa/laravel.nvim',
  dependencies = {
    'tpope/vim-dotenv',
    'nvim-telescope/telescope.nvim',
    'MunifTanjim/nui.nvim',
    'kevinhwang91/promise-async',
  },
  cmd = { 'Laravel' },
  keys = {
    { '<leader>la', ':Laravel artisan<cr>' },
    { '<leader>lr', ':Laravel routes<cr>' },
    { '<leader>lm', ':Laravel related<cr>' },
  },
  event = { 'VeryLazy' },
  opts = {
    use_providers = {},
  },
  config = true,
  init = function()
    local app = require('laravel').app

    local route_info_view = {}

    function route_info_view:get(route)
      return {
        virt_text = {
          { '[', 'comment' },
          { 'Method: ', 'comment' },
          { table.concat(route.methods, '|'), '@enum' },
          { ' Uri: ', 'comment' },
          { route.uri, '@enum' },
          { ']', 'comment' },
        },
      }
    end

    app:instance('route_info_view', route_info_view)
  end,
}
