if exists('g:loaded_ale_linters_javascript_eslint')
    finish
endif

let g:loaded_ale_linters_javascript_eslint = 1

function! ale_linters#javascript#eslint#Handle(buffer, lines)
    " Matches patterns line the following:
    "
    " <text>:47:14: Missing trailing comma. [Warning/comma-dangle]
    " <text>:56:41: Missing semicolon. [Error/semi]
    let pattern = '^<text>:\(\d\+\):\(\d\+\): \(.\+\) \[\(.\+\)\]'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let text = l:match[3]
        let marker_parts = l:match[4]
        let type = marker_parts[0]

        if len(marker_parts) == 2
            let text = text . ' (' . marker_parts[1] . ')'
        endif

        " vcol is Needed to indicate that the column is a character.
        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': l:match[1] + 0,
        \   'vcol': 0,
        \   'col': l:match[2] + 0,
        \   'text': text,
        \   'type': type ==# 'Warning' ? 'W' : 'E',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

call ALEAddLinter('javascript', {
\   'executable': 'eslint',
\   'command': 'eslint -f unix --stdin',
\   'callback': 'ale_linters#javascript#eslint#Handle',
\})
