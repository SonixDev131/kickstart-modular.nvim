return {
  'ravitemer/mcphub.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required for Job and HTTP requests
  },
  -- Don't lazy load since avante.nvim needs to access MCPHub immediately
  -- cmd = 'MCPHub', -- lazy load by default
  build = 'npm install -g mcp-hub@latest', -- Installs required mcp-hub npm module
  -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
  -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
  config = function()
    require('mcphub').setup {
      auto_approve = true, -- Auto approve mcp tool calls
      extensions = {
        codecompanion = {
          -- Show the mcp tool result in the chat buffer
          show_result_in_chat = true,
          -- Make chat #variables from MCP server resources
          make_vars = true,
          -- Create slash commands for prompts
          make_slash_commands = true,
        },
      },
    }

    -- Require custom MCP servers
    -- require('mcphub').add_server('search', require 'custom.mcp_servers.search_server')
  end,
}
