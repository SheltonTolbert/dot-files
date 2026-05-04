source ~/.zsh_api_keys
source ~/.config/zsh/.zsh_env_vars

source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/.zsh_config
source ~/.config/zsh/.zsh_aliases

## Look into autoload and setopt
source ~/.config/zsh/.zsh_functions
source ~/.config/zsh/.zsh_plugins

eval "$(mise activate zsh)"

eval "$(starship init zsh)"
export PATH="/opt/homebrew/opt/ffmpeg@6/bin:$PATH"
autoload -U compinit; compinit


source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sheltontolbert/.tmp/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sheltontolbert/.tmp/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sheltontolbert/.tmp/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sheltontolbert/.tmp/google-cloud-sdk/completion.zsh.inc'; fi
