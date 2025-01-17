local require = require("noice.util.lazy")
local Markdown = require("noice.text.markdown")

local Config = require("noice.config")
local Format = require("noice.lsp.format")
local Message = require("noice.message")

local M = {}

function M.setup()
  if Config.options.lsp.override["cmp.entry.get_documentation"] then
    require("cmp.entry").get_documentation = function(self)
      local item = self:get_completion_item()
      if item.documentation then
        return Format.format_markdown(item.documentation)
      end
      return {}
    end
  end

  if Config.options.lsp.override["vim.lsp.util.convert_input_to_markdown_lines"] then
    vim.lsp.util.convert_input_to_markdown_lines = function(input, contents)
      contents = contents or {}
      local ret = Format.format_markdown(input)
      vim.list_extend(contents, ret)
      return contents
    end
  end

  if Config.options.lsp.override["vim.lsp.util.stylize_markdown"] then
    vim.lsp.util.stylize_markdown = function(buf, contents, _opts)
      local text = table.concat(contents, "\n")
      local message = Message("lsp")
      Markdown.format(message, text)
      message:render(buf, Config.ns)
      Markdown.keys(buf)
      return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    end
  end
end

return M
