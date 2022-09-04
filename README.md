# gobf.nvim
* Git open blob file (gobf) plugin for neovim.

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

```
Plug 'senkentarou/gobf.nvim'
```

## Setup
* Please set your nvim confg before use.
```
require('gobf').setup {}
```

* For customizing, please setup as below,
```
require('gobf').setup {
  default_remote = 'upstream',
  default_branches = {
    'main',
    'master',
    'develop'
  }
}
```

## Usage
* Please execute `:Gobf` command on target line, then [github](https://github.com/) blob page is opened following commit hash on your web browser.
* You could set your git remote as an argument like `:Gobf upstream`
* You could select lines and execute `:Gobf` on visual mode.

## Example keymappings
```
" open blob file on github.com
nnoremap <silent> <Leader>o :<C-u>Gobf<CR>
" open blob file with visual selected lines on github.com
vnoremap <silent> <Leader>o :Gobf<CR>
" open blob file as current hash revision on github.com
nnoremap <silent> <Leader>O :<C-u>lua require('gobf').open_git_blob_file({ on_current_hash = true })<CR>
" open blob file as current hash revision with visual selected lines on github.com
vnoremap <silent> <Leader>O :lua require('gobf').open_git_blob_file({ on_current_hash = true })<CR>
```

## For development
* Load under development plugin files on root repository.
  * (If you already installed this plugin thankfully, please comment out applying code before.)

```
nvim --cmd "set rtp+=."
```

## License
* MIT
