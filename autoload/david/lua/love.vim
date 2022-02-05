" Support cargo paths in gf
" https://github.com/bjornbytes/cargo
"
" I create cargo as S.assets and put my assets in assets/. Allow gf to take us
" to an asset.
function! david#lua#love#go_file() abort
    let symbol = expand('<cWORD>')
    if match(symbol, "S.assets") == 0
        let assets = finddir('assets', '.;')
        if !empty(assets)
            let assets = david#path#to_unix(assets)
            let path = substitute(symbol, '\.', '/', 'g')
            let path = substitute(path, '\w\zs\W*$', '', 'g')
            let path = substitute(path, '^S/assets', assets, 'g')
            let resolved = david#path#to_unix(path ..".*")
            if filereadable(resolved)
                " File exists, so gf can take us there.
                let path = resolved .."\<CR>"
                " else we'll stay in cmdline and let user enter the desired
                " extension.
            endif
            return ':edit '.. path
        endif
    endif
    return 'gf'
endfunction
