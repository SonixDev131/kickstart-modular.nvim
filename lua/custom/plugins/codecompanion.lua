return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
    {
      'Davidyz/VectorCode',
      version = '*',
      build = 'pipx upgrade vectorcode',
    },
  },
  config = function()
    local spinner = require 'custom.spinner'
    spinner:init()
    require('codecompanion').setup {
      adapters = {
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'claude-3.7-sonnet',
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'copilot',
          tools = {
            ['mcp'] = {
              -- Prevent mcphub from loading before needed
              callback = function()
                return require 'mcphub.extensions.codecompanion'
              end,
              description = 'Call tools and resources from the MCP Servers',
            },
          },
          roles = {
            llm = function(adapter)
              local model_name = ''
              if adapter.schema and adapter.schema.model and adapter.schema.model.default then
                local model = adapter.schema.model.default
                if type(model) == 'function' then
                  model = model(adapter)
                end
                model_name = '(' .. model .. ')'
              end
              return '  ' .. adapter.formatted_name .. model_name
            end,
            user = ' User',
          },
        },
        inline = { adapter = 'copilot' },
        cmd = { adapter = 'copilot' },
        keymaps = {
          send = {
            callback = function(chat)
              vim.cmd 'stopinsert'
              chat:submit()
            end,
            index = 1,
            description = 'Send',
          },
        },
      },
      extensions = {
        vectorcode = {
          opts = { add_tool = true, add_slash_command = true, tool_opts = {} },
        },
      },
      display = {
        chat = {
          show_settings = true,
        },
      },
    }

    vim.keymap.set({ 'n', 'v' }, '<Leader>cca', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.keymap.set({ 'n', 'v' }, '<Leader>cct', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
    vim.keymap.set('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd [[cab cc CodeCompanion]]
  end,
}
