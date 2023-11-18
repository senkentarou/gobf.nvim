scriptencoding utf-8

if exists('g:loaded_to_gobf')
    finish
endif
let g:loaded_to_gobf = 1

let s:save_cpo = &cpo
set cpo&vim

command! Gobf lua require('gobf').open_git_blob_file()
command! Gobfop lua require('gobf').open_git_blob_file({ on_permalink = true })

let &cpo = s:save_cpo
unlet s:save_cpo
