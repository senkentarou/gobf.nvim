local vim = vim

local DEFAULT_OPTIONS = {
  default_remote = 'origin',
  default_branches = {
    'main',
    'master',
    'develop'
  }
}

local function run(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  return string.gsub(result, '\n', ' ')
end

local function exists(path)
  local f = io.open(path, "r")

  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function check_git()
  -- check .git repository
  if not exists('.git') then
    error('fatal: .git repository does not exist.')
  end
end

local function remote_base_url(args)
  local target_remote = vim.g.gopr.default_remote
  if args and args.remote ~= nil and #args.remote > 0 then
    target_remote = args.remote
  end

  local git_remotes = run('git remote show')
  if not string.find(git_remotes, target_remote) then
    target_remote = DEFAULT_OPTIONS.default_remote
  end

  local git_remote_url = run('git ls-remote --get-url ' .. target_remote)
  local url_base = string.gsub(git_remote_url, '^.-github.com[:/]?(.*)%.git%s?$', '%1')
  if git_remote_url == url_base or #url_base <= 0 then
    error('fatal: could not open remote url about \'' .. git_remote_url .. '\'')
  end

  return url_base
end

--
-- Git open blob file
--
local gobf = {}

function gobf.setup(options)
  vim.g.gobf = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, options)
end

function gobf.open_git_blob_file(args)
  check_git()

  local url_base = remote_base_url(args)

  local branches = table.concat(vim.g.gobf.default_branches, '\\|')

  local blob_target = string.gsub(run('git branch | grep -o -m1 "\\(' .. branches .. '\\)"'), '%s+', '')
  if args and args.on_current_hash then
    blob_target = string.gsub(run('git log --pretty=%H -1'), '%s+', '')
  end

  local relative_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

  local target_url = 'https://github.com/' .. url_base .. '/blob/' .. blob_target .. '/' .. relative_path

  local _, start_line, _, _ = unpack(vim.fn.getpos("'<"))
  local _, end_line, _, _ = unpack(vim.fn.getpos("'>"))
  if start_line > 0 and end_line > 0 then
    target_url = target_url .. '#L' .. start_line .. '-L' .. end_line
  end

  os.execute('open ' .. target_url)
  print('opened: ' .. target_url)
end

return gobf
