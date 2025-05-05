return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim', branch = 'master' },
    'ravitemer/mcphub.nvim',
    {
      'Davidyz/VectorCode',
      version = '*',
      build = 'pipx upgrade vectorcode',
    },
    {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      event = 'InsertEnter',
      config = function()
        require('copilot').setup {}
      end,
    },
    {
      'ravitemer/mcphub.nvim',
      cmd = 'MCPHub', -- lazy load by default
      build = 'npm install -g mcp-hub@latest', -- Installs required mcp-hub npm module
      config = function()
        require('mcphub').setup {
          auto_approve = true, -- Auto approve mcp tool calls
          -- Extensions configuration
          extensions = {
            codecompanion = {
              -- Show the mcp tool result in the chat buffer
              -- NOTE:if the result is markdown with headers, content after the headers wont be sent by codecompanion
              show_result_in_chat = true,
              make_vars = true, -- make chat #variables from MCP server resources
              make_slash_commands = true,
            },
          },
        }
      end,
    },
  },
  config = function()
    require('codecompanion').setup {
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        vectorcode = {
          opts = {
            add_tool = true,
          },
        },
      },
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
            ['all_in_one'] = {
              description = "verything but the kitchen sink (we're working on that)",
              system_prompt = "You are an agent, please keep going until the user's query is completely resolved, before ending your turn and yielding back to the user. Only terminate your turn when you are sure that the problem is solved. If you are not sure about file content or codebase structure pertaining to the user's request, use your tools to read files and gather the relevant information: do NOT guess or make up an answer. You MUST plan extensively before each function call, and reflect extensively on the outcomes of the previous function calls. DO NOT do this entire process by making function calls only, as this can impair your ability to solve the problem and think insightfully.",
              tools = {
                'cmd_runner',
                'editor',
                'files',
                'mcp',
              },
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
      display = {
        chat = {
          show_settings = false,
        },
      },
    }

    vim.keymap.set({ 'n', 'v' }, '<Leader>cca', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
    vim.keymap.set({ 'n', 'v' }, '<Leader>cct', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
    vim.keymap.set('v', '<leader>a', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd [[cab cc CodeCompanion]]
    require('custom.spinner'):init()
  end,
}
