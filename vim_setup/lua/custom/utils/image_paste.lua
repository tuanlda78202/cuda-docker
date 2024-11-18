local M = {}

local function download_image(image_url, local_path)
  -- Use vim.fn.system() to call curl to download the image
  local command = 'curl -sLo ' .. local_path .. ' --create-dirs ' .. image_url
  local result = vim.fn.system(command)

  -- Check for curl errors
  if vim.v.shell_error ~= 0 then
    print('Error downloading image: ' .. result)
    return false
  end

  return true
end

function M.insert_image_markdown(local_path)
  -- The Markdown format for images
  local markdown_text = '![](' .. local_path .. ')'

  -- Insert the markdown text at the current cursor position
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local current_line = vim.api.nvim_get_current_line()
  local new_line = current_line:sub(1, col-1) .. markdown_text .. current_line:sub(col)
  vim.api.nvim_set_current_line(new_line)
end

-- Command registration
function M.setup()
  vim.api.nvim_create_user_command('CopyImage',
    function(opts)
      -- Get the current buffer's directory
      local current_dir = vim.fn.expand('%:p:h')
      local filename = opts.args:match("^.+/(.+)$")
      local local_path = current_dir .. '/images/' .. filename

      -- Download the image
      if download_image(opts.args, local_path) then
        M.insert_image_markdown('images/' .. filename)
      end
    end,
    {nargs = 1, complete = 'file'})
end

return M

