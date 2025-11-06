ls ~/.dotfiles/src/scripts/snippets | fzf | xargs -I {} sh -c 'cat ~/.dotfiles/src/scripts/snippets/{}' | pbcopy
