# Environment
export DOTFILES="$HOME/dotfiles"
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$(go env GOPATH)/bin:$PATH"

# Sheldon plugin manager
eval "$(sheldon source)"

# Zsh completion (after sheldon so zsh-completions fpath is available)
autoload -Uz compinit
compinit
bindkey -e
# bindkey '^f' autosuggest-accept

# Tool inits
eval "$(fnm env --use-on-cd)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Starship prompt (must be last)
eval "$(starship init zsh)"

# Aliases
alias ls="eza --icons=always"
alias ll="eza -la --icons=always"
alias cat="bat"
alias cd="z"
alias vim="nvim"
alias python="python3"
alias pip="pip3"
alias k="kubectl"
alias lg="lazygit"
alias path='echo $PATH | tr ":" "\n"'
alias chrome-debug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'

mkd() { mkdir -p "$1" && cd "$1" }

# Local overrides
[[ -f ~/.zshlocal ]] && source ~/.zshlocal

alias gst='git status'

alias gp='git pull'
