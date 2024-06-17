export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export ZSH="/Users/sheltontolbert/.oh-my-zsh"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
export EDITOR="nvim"

export ZSHCONFIG=~/.zshrc
export VIMCONFIG=~/.config/nvim
export VIMDATA=~/.local/share/nvim
export ML_PATH=~/repos/handson-ml/ml

ZSH_THEME="agnoster"

plugins=(
git 
asdf 
npm 
yarn
brew 
colorize 
gem 
git-extras 
heroku 
node 
npm
rails 
ruby
zsh-autosuggestions
z
)

source $ZSH/oh-my-zsh.sh

alias soma="bundle exec puma"
alias somag="RAILS_ENV=glia rails s"

alias axon="iex -S mix phx.server"
alias axong="MIX_ENV=glia iex -S mix phx.server"

alias sqlcli="psql dscout_development"

alias dscout="cd ~/repos/dscout"
alias dscoutd="cd ~/repos/dscout/apps/dendra; yarn start"
alias dscouta="cd ~/repos/dscout/apps/axon; mix phx.server"
alias dscouts="cd ~/repos/dscout/apps/soma; bundle exec puma"

alias vi="vim"
alias vim="nvim"

alias dendrad="cd ~/repos/dscout/apps/dendra; vim .;"

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias mondays="git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)'"
alias lint="yarn lint --quiet"

alias invert="~/scripts/mac-inverse-click/inverse_mouse"
alias gpt="~/repos/gpt-cli/gpt.py"
alias issues='jira issues list -a$(jira me) -s"To Do"'
alias dev='tmuxinator start dev'
alias fin='echo gpt: a brief outro for a lunch and learn about command line workflows followed by a haiku about how shelton is a the number one lunch and learn host; echo ; gpt -p "a short outro for a lunch and learn about command line workflows followed by a new line followed by a haiku about how shelton is the number one lunch and learn presenter"'


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/sheltontolbert/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/sheltontolbert/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/sheltontolbert/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/sheltontolbert/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

eval "$(starship init zsh)"
