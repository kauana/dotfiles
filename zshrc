# Environment
export DOTFILES="$HOME/dotfiles"
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

# Sheldon plugin manager
eval "$(sheldon source)"

# Tool inits
eval "$(fnm env --use-on-cd)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Starship prompt (must be last)
eval "$(starship init zsh)"

# Aliases
alias ls="eza --icons"
alias cat="bat"
alias cd="z"
alias vim="nvim"
alias python="python3"
alias pip="pip3"
alias k="kubectl"
alias path='echo $PATH | tr ":" "\n"'
alias chrome-debug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'

mkd() { mkdir -p "$1" && cd "$1" }

# Local overrides
[[ -f ~/.zshlocal ]] && source ~/.zshlocal
