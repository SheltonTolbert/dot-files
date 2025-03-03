#!/bin/bash

# nvim --headless -c "echomsg 'Hello, world!'" -c "qa!"

touch ~/.tmp/commitout

nvim --headless \
--cmd ":luafile ~/.config/nvim/lua/plugins/code-companion/hooks.lua" \
-c ":e ~/.tmp/commitout" \
-c "normal! v" \
-c ":CodeCompanion /gen_commit" \
> /dev/null 2>&1

cat ~/.tmp/commitout


