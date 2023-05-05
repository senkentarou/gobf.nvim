local vim = vim

local DEFAULT_OPTIONS = {
  default_remote = 'origin',
  default_branches = {
    'main',
    'master',
    'develop',
  },
}

local function run(command)
  local handle = io.popen(command)

  if handle then
    local result = handle:read("*a")
    handle:close()

    return string.gsub(result, '\n', ' ')
  end

  return ''
end

local function exists(path)
  local f = io.open(path, "r")

  if f ~= nil then
    io.close(f)
    return true
  end

  return false
end

--
-- Git open blob file
--
local gobf = {}

function gobf.setup(options)
  vim.g.gobf = vim.tbl_deep_extend('force', DEFAULT_OPTIONS, options)
end

function gobf.open_git_blob_file(args)
  if not exists('.git') then
    vim.notify('fatal: .git repository does not exist.', vim.log.levels.ERROR)
    return
  end

  -- detect remote (origin / upstream / etc...)
  local target_remote = vim.g.gopr.default_remote
  if args and args.remote ~= nil and #args.remote > 0 then
    target_remote = args.remote
  end

  local git_remotes = run('git remote show')
  if not string.find(git_remotes, target_remote) then
    target_remote = DEFAULT_OPTIONS.default_remote
  end

  -- get remote base url
  local git_remote_url = run('git ls-remote --get-url ' .. target_remote)
  local url_base = string.gsub(git_remote_url, '^.-github.com[:/]?(.-)%s?$', '%1') -- only github...
  local remote_base = string.gsub(url_base, '^(.-)%.git$', '%1') -- clean .git postfix

  if git_remote_url == remote_base or #remote_base <= 0 then
    vim.notify('fatal: could not open remote url about \'' .. git_remote_url .. '\'', vim.log.levels.ERROR)
    return
  end

  -- detect blob branch (master / main / develop / etc...) or hash
  local blob_target = 'master'
  if args and args.on_current_hash then
    blob_target = string.gsub(run('git log --pretty=%H -1'), '%s+', '')
  elseif args and args.target_hash then
    blob_target = args.target_hash
  else
    local branches = string.gsub(run('git branch --format="%(refname:short)"'), '%s+$', '')
    local target_branches = vim.g.gobf.default_branches
    for i = 1, #target_branches do
      if string.find(branches, target_branches[i]) then
        blob_target = target_branches[i]
        break
      end
    end
  end

  local relative_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  local target_url = 'https://github.com/' .. remote_base .. '/blob/' .. blob_target .. '/' .. relative_path

  local _, start_line, _, _ = unpack(vim.fn.getpos("'<"))
  local _, end_line, _, _ = unpack(vim.fn.getpos("'>"))
  if start_line > 0 and end_line > 0 then
    target_url = target_url .. '#L' .. start_line .. '-L' .. end_line
  end

  os.execute('open ' .. target_url)
  vim.notify('opened: ' .. target_url)
end

return gobf
