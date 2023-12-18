local vim = vim

local DEFAULT_OPTIONS = {
  default_remote = 'origin',
  default_branch = 'main',
  possible_branches = {
    'main',
    'master',
    'develop',
  },
}

local function open_remote(url)
  if vim.fn.executable('open') then
    -- open remote directly.
    os.execute('open ' .. url)
    vim.notify('opened: ' .. url)
  else
    -- copy url if it cannot open.
    vim.fn.setreg("+", url)
    vim.fn.setreg("*", url)
    vim.notify('copied: ' .. url)
  end
end

local function run(command)
  local handle = io.popen(command)

  if handle then
    local result = handle:read("*a")
    handle:close()

    return string.gsub(result, '\n', ' ')
  end

  return ''
end

local function find_branch()
  local result = vim.g.gobf.default_branch
  local target_branches = vim.g.gobf.possible_branches

  for i = 1, #target_branches do
    if string.find(string.gsub(run('git branch --format="%(refname:short)"'), '%s+$', ''), target_branches[i]) then
      result = target_branches[i]
      break
    end
  end

  return result
end

local function is_visual_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' or mode == '' then
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
  if vim.fn.empty(vim.fn.glob('.git')) == 1 then
    vim.notify('fatal: .git does not exist on current directory.', vim.log.levels.ERROR)
    return
  end

  if vim.fn.empty(vim.fn.expand("%")) == 1 then
    vim.notify('fatal: current file is empty.', vim.log.levels.ERROR)
    return
  end

  args = args or {}

  -- detect remote (origin / upstream / etc...)
  local target_remote = args.remote or vim.g.gobf.default_remote

  if not string.find(run('git remote show'), target_remote) then
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

  -- detect blob branch (master / main / develop / etc...)
  local target_blob_branch = find_branch()

  if args.on_permalink then
    target_blob_branch = string.gsub(run('git log --pretty=%H -1 $(git branch -r --format="%(refname:short)" | grep ' .. target_blob_branch .. ' | grep ' .. target_remote .. ')'),
                                     '%s+', '')
  end

  -- assemble url
  local relative_file_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
  local target_url = 'https://github.com/' .. remote_base .. '/blob/' .. target_blob_branch .. '/' .. relative_file_path

  if is_visual_mode() then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > 0 and end_line > 0 then
      target_url = target_url .. '#L' .. vim.fn.min({
        start_line,
        end_line,
      }) .. '-L' .. vim.fn.max({
        start_line,
        end_line,
      })
    end
  end

  open_remote(target_url)
end

return gobf
