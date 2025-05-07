return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- Exact version management

  config = function()
    require('avante').setup {
      -- Provider configuration
      provider = 'copilot',
      cursor_applying_provider = 'groq',
      auto_suggestions_provider = 'copilot',
      copilot = {
        model = 'claude-3.7-sonnet',
      },

      behaviour = {
        enable_cursor_planning_mode = true, -- Whether to enable Cursor Planning Mode. Default to false.
        enable_claude_text_editor_tool_mode = false, -- Whether to enable Claude Text Editor Tool Mode.
      },

      -- Vendor configurations
      vendors = {
        groq = {
          __inherited_from = 'openai',
          api_key_name = 'GROQ_API_KEY',
          endpoint = 'https://api.groq.com/openai/v1/',
          model = 'llama-3.3-70b-versatile',
          max_completion_tokens = 32768,
        },
      },

      rag_service = {
        enabled = true, -- Enables the RAG service
        host_mount = os.getenv 'HOME' .. '/projects', -- Host mount path for the rag service
        provider = 'openai', -- The provider to use for RAG service (e.g. openai or ollama)
        llm_model = '', -- The LLM model to use for RAG service
        embed_model = '', -- The embedding model to use for RAG service
        endpoint = 'https://api.openai.com/v1', -- The API endpoint for RAG service
      },

      -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
      system_prompt = function()
        local hub = require('mcphub').get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require('mcphub.extensions.avante').mcp_tool(),
        }
      end,
    }

    -- prefil edit window with common scenarios to avoid repeating query and submit immediately
    local prefill_edit_window = function(request)
      require('avante.api').edit()
      local code_bufnr = vim.api.nvim_get_current_buf()
      local code_winid = vim.api.nvim_get_current_win()
      if code_bufnr == nil or code_winid == nil then
        return
      end
      vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
      -- Optionally set the cursor position to the end of the input
      vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
      -- Simulate Ctrl+S keypress to submit
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
    end

    -- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
    local avante_grammar_correction = 'Correct the text to standard English, but keep any code blocks inside intact.'
    local avante_keywords = 'Extract the main keywords from the following text'
    local avante_code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
    local avante_optimize_code = 'Optimize the following code'
    local avante_summarize = 'Summarize the following text'
    local avante_translate = 'Translate this into Chinese, but keep any code blocks inside intact'
    local avante_explain_code = 'Explain the following code'
    local avante_complete_code = 'Complete the following codes written in ' .. vim.bo.filetype
    local avante_add_docstring = 'Add docstring to the following codes'
    local avante_fix_bugs = 'Fix the bugs inside the following codes if any'
    local avante_add_tests = 'Implement tests for the following code'

    require('which-key').add {
      { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
      {
        mode = { 'n', 'v' },
        {
          '<leader>ag',
          function()
            require('avante.api').ask { question = avante_grammar_correction }
          end,
          desc = 'Grammar Correction(ask)',
        },
        {
          '<leader>ak',
          function()
            require('avante.api').ask { question = avante_keywords }
          end,
          desc = 'Keywords(ask)',
        },
        {
          '<leader>al',
          function()
            require('avante.api').ask { question = avante_code_readability_analysis }
          end,
          desc = 'Code Readability Analysis(ask)',
        },
        {
          '<leader>ao',
          function()
            require('avante.api').ask { question = avante_optimize_code }
          end,
          desc = 'Optimize Code(ask)',
        },
        {
          '<leader>am',
          function()
            require('avante.api').ask { question = avante_summarize }
          end,
          desc = 'Summarize text(ask)',
        },
        {
          '<leader>an',
          function()
            require('avante.api').ask { question = avante_translate }
          end,
          desc = 'Translate text(ask)',
        },
        {
          '<leader>ax',
          function()
            require('avante.api').ask { question = avante_explain_code }
          end,
          desc = 'Explain Code(ask)',
        },
        {
          '<leader>ac',
          function()
            require('avante.api').ask { question = avante_complete_code }
          end,
          desc = 'Complete Code(ask)',
        },
        {
          '<leader>ad',
          function()
            require('avante.api').ask { question = avante_add_docstring }
          end,
          desc = 'Docstring(ask)',
        },
        {
          '<leader>ab',
          function()
            require('avante.api').ask { question = avante_fix_bugs }
          end,
          desc = 'Fix Bugs(ask)',
        },
        {
          '<leader>au',
          function()
            require('avante.api').ask { question = avante_add_tests }
          end,
          desc = 'Add Tests(ask)',
        },
      },
    }

    require('which-key').add {
      { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
      {
        mode = { 'v' },
        {
          '<leader>aG',
          function()
            prefill_edit_window(avante_grammar_correction)
          end,
          desc = 'Grammar Correction',
        },
        {
          '<leader>aK',
          function()
            prefill_edit_window(avante_keywords)
          end,
          desc = 'Keywords',
        },
        {
          '<leader>aO',
          function()
            prefill_edit_window(avante_optimize_code)
          end,
          desc = 'Optimize Code(edit)',
        },
        {
          '<leader>aC',
          function()
            prefill_edit_window(avante_complete_code)
          end,
          desc = 'Complete Code(edit)',
        },
        {
          '<leader>aD',
          function()
            prefill_edit_window(avante_add_docstring)
          end,
          desc = 'Docstring(edit)',
        },
        {
          '<leader>aB',
          function()
            prefill_edit_window(avante_fix_bugs)
          end,
          desc = 'Fix Bugs(edit)',
        },
        {
          '<leader>aU',
          function()
            prefill_edit_window(avante_add_tests)
          end,
          desc = 'Add Tests(edit)',
        },
      },
    }
  end,

  -- Dependencies
  dependencies = {
    -- Core dependencies
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',

    -- Provider dependencies
    'zbirenbaum/copilot.lua',

    -- MCPHub integration
    {
      'ravitemer/mcphub.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      build = 'npm install -g mcp-hub@latest',
      config = function()
        require('mcphub').setup {
          auto_approve = true,
          extensions = {
            avante = {
              make_slash_commands = true,
            },
          },
        }
      end,
    },

    -- Markdown rendering
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },

    -- 'folke/snacks.nvim',

    -- Disabled/Optional dependencies
    -- 'stevearc/dressing.nvim',

    -- Image paste support (disabled by default)
    -- {
    --   'HakonHarnes/img-clip.nvim',
    --   event = 'VeryLazy',
    --   opts = {
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = { insert_mode = true },
    --       use_absolute_path = true, -- required for Windows
    --     },
    --   },
    -- },
  },
}
