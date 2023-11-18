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
  default_branch = 'main',
  possible_branches = {
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
vnoremap <silent> <Leader>o <CMD>Gobf<CR>
" open blob file as current remote revision on github.com
nnoremap <silent> <Leader>O :<C-u>Gobfop<CR>
" open blob file as current remote revision with visual selected lines on github.com
vnoremap <silent> <Leader>O <CMD>Gobfop<CR>
```

## For development
* Load under development plugin files on root repository.
  * (If you already installed this plugin thankfully, please comment out applying code before.)

```
nvim --cmd "set rtp+=."
```

## License
* MIT
