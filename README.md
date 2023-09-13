### **dot-files:** 
    
    [this is mostly for me, but it's for you too](https://www.youtube.com/watch?v=RQZW98gtLb4)

#### installation

    the setup script installs a bunch of programs and dependencies that make up the tools of my dev environment
    stuff like tmux, neovim, node, oh-my-zsh, and runescape
    it also downloads a nerd font, which you'll have to set yourself
    
note: this is for macos only, I may put together a linux flavor soon

- clone the repo `git clone https://github.com/SheltonTolbert/dot-files.git ~/.dotfiles`
- install deps and setup sym-links `~/.dotfiles/install`

---

#### keeping up to date

- run `~/.dotfiles/update` to update sym-links. this skips the dependency installiation step
