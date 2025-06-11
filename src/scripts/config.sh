#!/bin/bash

CONFIG_DIR="$(cd "$HOME/.config" && pwd )"

if [ ! -d "$CONFIG_DIR" ]; then
  echo "Directory $CONFIG_DIR does not exist."
  exit 1
fi

if [ -z "$1" ]; then
  QUERY=""
else
  QUERY="$1"
fi

FZF_LABEL=" Config "
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --border-label="'$FZF_LABEL'" 
  --color=prompt:-1,spinner:-1,pointer:-1,header:-1
  --select-1
  --border="rounded"
  --border-label-pos="0"
  '

MENU_HEADER="Config"
selected=$( ls -a "$CONFIG_DIR" | grep -vE '^\.$|^\.\.$|^\.DS_Store$' | fzf --query="$QUERY" --header="$MENU_HEADER" --no-clear)

if [ -z "$selected" ]; then
  echo "No config selected."
  exit 1
fi

nvim -c ":NvimTreeOpen<CR>" "$CONFIG_DIR/$selected"
