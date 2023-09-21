source ~/.config/zsh/.zsh_env_vars
source ~/.config/zsh/.zsh_secrets
source ~/.config/zsh/.zsh_config
source $ZSH/oh-my-zsh.sh
source ~/.zsh_api_keys
source ~/.config/zsh/.zsh_aliases

## Look into autoload and setopt
source ~/.config/zsh/.zsh_functions

eval "$(starship init zsh)"
