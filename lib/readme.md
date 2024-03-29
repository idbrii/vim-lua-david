# VS2017 and newer

```bat
pip install hererocks
hererocks -l 5.4 -r latest c:/david/apps/lua54
call c:\david\apps\lua54\bin\activate.bat
call C:\david\settings\daveconfig\win\visualstudio\vcvars\vcvars_vs2017.bat
which luarocks
luarocks install luacheck
luarocks install https://raw.githubusercontent.com/siffiejoe/lua-testy/master/testy-scm-0.rockspec
```

Add to path in local.vim:
```vim
    let lua_54 = expand('c:/david/apps/lua54/bin')
    if !david#add_to_path(lua_54)
        echoerr "Failed to find lua."
    endif
    if len($LUA_PATH_5_4) == 0
        let $LUA_PATH_5_4 = lua_54
    endif
```

Download a [release of stylua](https://github.com/JohnnyMorganz/StyLua/releases) and save as ~/.vim-cache/bin/stylua

# VS2008

Download:

* Windows x64 Executables (lua-5.3.5_Win64_bin.zip)
    * http://luabinaries.sourceforge.net/download.html
    * MUST be x64. If you get win32 with x64 vim, it will give "E370: Could not load library lua53.dll"

and put them here:

    ~/.vim/bundle/lua-david$ tree lib
        lib
        ├── lua-5.3
        │   ├── lua53.dll
        │   ├── lua53.exe
        │   ├── luac53.exe
        │   └── wlua53.exe
        └── readme.md


In theory, you can also download the static libs and install luarocks like so:

    .\install.bat   /P C:\david\apps\lua\luarocks-5.3 /selfcontained /noadmin /LUA %USERPROFILE%\.vim\bundle\lua-david\lib\lua-5.3

However, that didn't actually work. luarocks doesn't understand this lib file
and barfs [1]. Maybe because I'm using VS2008 and luabinaries only offers
VS2010 and newer.

Instead, I installed luaforwindows and followed the instructions on this
comment [2] to get luarocks to have a more recent version of luafilesystem
(followed verbatim because using a more recent luarocks 2.4.2 failed). I still
couldn't get luacheck to install, so I used `luarocks install luacheck
--deps-mode=none` which didn't work on other environments. Now I finally have
luacheck working.

Since luaforwindows provides lua 5.1 and vim demands lua 5.3, we need both to
run luacheck (via ale) and allow if_lua (for lua vim plugins).

[1]: https://github.com/keplerproject/luafilesystem/issues/82
[2]: https://github.com/rjpcomputing/luaforwindows/issues/80#issuecomment-193851597
