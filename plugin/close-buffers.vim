" close-buffers.vim
" Commands to delete buffers
" Author:	Asheq Imran <https://github.com/Asheq>
" License:	Same license as Vim itself
" Version: 0.5

" Setup
" --------------------
if exists("g:loaded_close_buffers")
  finish
endif
let g:loaded_close_buffers = 1

let s:save_cpo = &cpo
set cpo&vim

" Helper variables
" --------------------
let s:options =  ["menu", "other", "hidden", "nameless", "all", "select", "this"]
let s:menu_options = ["cancel", "other", "hidden", "nameless", "all", "select", "this"]

function! s:get_menu_confirm_string()
  let menu_options = copy(s:menu_options)
  let menu_options_with_amp = map(menu_options, '"&" . v:val')
  return join(menu_options_with_amp, "\n")
endfunction

let s:menu_confirm_string = s:get_menu_confirm_string()

" Commands
" --------------------
if exists(':Bdelete')
  echoerr 'close-buffers.vim: You already have a ":Bdelete" command defined'
else
  command -bang -nargs=1 -complete=customlist,s:bclose_completion_options Bdelete call s:bclose('bdelete', <bang>0, <f-args>)
endif

if exists(':Bwipeout')
  echoerr 'close-buffers.vim: You already have a ":Bwipeout" command defined'
else
  command -bang -nargs=1 -complete=customlist,s:bclose_completion_options Bwipeout call s:bclose('bwipeout', <bang>0, <f-args>)
endif

" Functions
" --------------------
function! s:bclose(command, bang, option)
  if index(s:options, a:option) < 0
    echoerr 'close-buffers.vim: Invalid option: ' . a:option
  endif

  if (a:option == 'menu')
    call s:bclose_menu(a:command, a:bang)
  elseif (a:option == 'select')
    pwd
    execute 'ls' . (a:command == 'bwipeout' ? '!' : '')
    call feedkeys(':' . s:append_bang(a:command, a:bang) . ' ', 'n')
  elseif (a:option == 'this')
    execute s:append_bang(a:command, a:bang)
  else
    if (a:option == 'other')
      let filtered_bufinfo = filter(s:get_relevant_bufinfo(a:command), 'v:val.bufnr != bufnr("%")')
    elseif (a:option == 'hidden')
      let filtered_bufinfo = filter(s:get_relevant_bufinfo(a:command), 'empty(v:val.windows)')
    elseif (a:option == 'nameless')
      let filtered_bufinfo = filter(s:get_relevant_bufinfo(a:command), 'v:val.name == ""')
    elseif (a:option == 'all')
      let filtered_bufinfo = s:get_relevant_bufinfo(a:command)
    endif

    let buffer_numbers = map(filtered_bufinfo, 'v:val.bufnr')
    call s:close_buffers(a:command, a:bang, buffer_numbers)
  endif
endfunction

function! s:bclose_completion_options(ArgLead, CmdLine, CursorPos) abort
  let matches = []
  for f in s:options
    if f =~ '^' . a:ArgLead
      call add(matches, f)
    endif
  endfor
  return matches
endfunction

function! s:bclose_menu(command, bang)
  let word = a:command == 'bdelete' ? 'Delete' : 'Wipeout'
  let choice = confirm(word . " Buffers?", s:menu_confirm_string, 1)
  if (choice != 1)
    let option = s:menu_options[choice - 1]
    call s:bclose(a:command, a:bang, option)
  endif
endfunction

" Helper functions
" --------------------
function! s:close_buffers(command, bang, buffer_numbers)
  if !empty(a:buffer_numbers)
    execute s:append_bang(a:command, a:bang) . ' ' . join(a:buffer_numbers)
  endif
endfunction

function! s:append_bang(command, bang)
  return a:command . (a:bang ? '!' : '')
endfunction

function! s:get_relevant_bufinfo(command)
  if (a:command == 'bdelete')
    return filter(getbufinfo(), 'v:val.listed')
  elseif (a:command == 'bwipeout')
    return getbufinfo()
  else
    echoerr 'close-buffers.vim: Invalid command: ' . a:command
  endif
endfunction

" Obsolete Commands
" --------------------
if !exists(':CloseAllBuffers')
  command -bang CloseAllBuffers echoerr '":CloseAllBuffers" is obsolete. Use ":Bdelete all" instead.'
endif

if !exists(':CloseHiddenBuffers')
  command -bang CloseHiddenBuffers echoerr '":CloseHiddenBuffers" is obsolete. Use ":Bdelete hidden" instead.'
endif

if !exists(':CloseNamelessBuffers')
  command -bang CloseNamelessBuffers echoerr '":CloseNamelessBuffers" is obsolete. Use ":Bdelete nameless" instead.'
endif

if !exists(':CloseOtherBuffers')
  command -bang CloseOtherBuffers echoerr '":CloseOtherBuffers" is obsolete. Use ":Bdelete other" instead.'
endif

if !exists(':CloseSelectedBuffers')
  command -bang CloseSelectedBuffers echoerr '":CloseSelectedBuffers" is obsolete. Use ":Bdelete select" instead.'
endif

if !exists(':CloseThisBuffer')
  command -bang CloseThisBuffer echoerr '":CloseThisBuffer" is obsolete. Use ":Bdelete this" instead.'
endif

if !exists(':CloseBuffers')
  command -bang CloseBuffers echoerr '":CloseBuffers" is obsolete. Use ":Bdelete menu" instead.'
endif

if !exists(':CloseBuffersMenu')
  command -bang CloseBuffersMenu echoerr '":CloseBuffersMenu" is obsolete. Use ":Bdelete menu" instead.'
endif

" Teardown
" --------------------
let &cpo = s:save_cpo
unlet s:save_cpo
