source ~/.zsh_api_keys
source ~/.config/zsh/.zsh_env_vars

source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/.zsh_config
source ~/.config/zsh/.zsh_aliases

## Look into autoload and setopt
source ~/.config/zsh/.zsh_functions

eval "$(starship init zsh)"
export PATH="/opt/homebrew/opt/ffmpeg@6/bin:$PATH"
autoload -U compinit; compinit

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/sheltontolbert/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
