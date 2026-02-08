set shell := ["bash", "-cu"]

dotfiles := env("HOME") / "dotfiles"

# Run full setup
setup: backup brew symlinks gitconfig-setup shell
  @echo "Setup complete! Run 'exec zsh' to reload your shell."

# Backup old dotfiles repo
backup:
  #!/usr/bin/env bash
  set -euo pipefail
  if [[ -d "$HOME/.dotfiles" && ! -d "$HOME/.dotfiles.bak" ]]; then
    echo "Backing up ~/.dotfiles to ~/.dotfiles.bak..."
    mv "$HOME/.dotfiles" "$HOME/.dotfiles.bak"
  elif [[ -d "$HOME/.dotfiles.bak" ]]; then
    echo "Backup already exists at ~/.dotfiles.bak, skipping."
  else
    echo "No ~/.dotfiles found, skipping backup."
  fi

# Install Homebrew and bundle packages
brew:
  #!/usr/bin/env bash
  set -euo pipefail
  if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "Installing packages from Brewfile..."
  brew bundle --file={{dotfiles}}/Brewfile

# Create all symlinks
symlinks:
  #!/usr/bin/env bash
  set -euo pipefail

  link() {
    local src="$1" dst="$2"
    if [[ -L "$dst" ]]; then
      rm "$dst"
    elif [[ -e "$dst" ]]; then
      echo "Backing up $dst to ${dst}.bak"
      mv "$dst" "${dst}.bak"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "Linked $dst -> $src"
  }

  # config/* directories -> ~/.config/*
  for item in {{dotfiles}}/config/*/; do
    name=$(basename "$item")
    link "$item" "$HOME/.config/$name"
  done

  # starship.toml is a file, not a directory
  link "{{dotfiles}}/config/starship.toml" "$HOME/.config/starship.toml"

  # zshrc
  link "{{dotfiles}}/zshrc" "$HOME/.zshrc"

  # claude directory
  link "{{dotfiles}}/claude" "$HOME/.claude"

# Set up gitconfig with private values + include
gitconfig-setup:
  #!/usr/bin/env bash
  set -euo pipefail

  gitconfig="$HOME/.gitconfig"

  # Already set up — check for include path
  if [[ -f "$gitconfig" ]] && grep -q "path = ~/dotfiles/gitconfig" "$gitconfig"; then
    echo "~/.gitconfig already includes ~/dotfiles/gitconfig, skipping."
    exit 0
  fi

  # If it's a symlink, dereference it first
  if [[ -L "$gitconfig" ]]; then
    echo "Dereferencing ~/.gitconfig symlink..."
    target=$(readlink "$gitconfig")
    rm "$gitconfig"
    # Try original target, then fall back to .bak location
    if [[ -f "$target" ]]; then
      cp "$target" "$gitconfig"
    elif [[ -f "${target/.dotfiles/.dotfiles.bak}" ]]; then
      cp "${target/.dotfiles/.dotfiles.bak}" "$gitconfig"
    fi
  fi

  # Ensure file exists for git config reads
  touch "$gitconfig"

  # Extract private values from existing config
  name=$(git config --global user.name 2>/dev/null || echo "")
  email=$(git config --global user.email 2>/dev/null || echo "")
  gpgsign=$(git config --global commit.gpgsign 2>/dev/null || echo "")
  signingkey=$(git config --global user.signingkey 2>/dev/null || echo "")

  # Write clean ~/.gitconfig with only private values + include
  {
    printf "[user]\n"
    printf "  name = %s\n" "$name"
    printf "  email = %s\n" "$email"
    if [[ -n "$signingkey" ]]; then
      printf "  signingkey = %s\n" "$signingkey"
    fi
    if [[ "$gpgsign" == "true" ]]; then
      printf "\n[commit]\n"
      printf "  gpgsign = true\n"
    fi
    printf "\n[include]\n"
    printf "  path = ~/dotfiles/gitconfig\n"
  } > "$gitconfig"

  echo "Wrote ~/.gitconfig with private values + include."

# Set default shell to zsh
shell:
  #!/usr/bin/env bash
  set -euo pipefail
  current_shell=$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}')
  zsh_path=$(which zsh)
  if [[ "$current_shell" == *zsh ]]; then
    echo "Shell is already zsh."
  else
    echo "Changing default shell to zsh (may require password)..."
    chsh -s "$zsh_path" || echo "Warning: chsh failed. Run manually: chsh -s $zsh_path"
  fi

# Update packages and plugins
update:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Updating Homebrew packages..."
  brew update && brew upgrade && brew cleanup
  echo "Updating sheldon plugins..."
  sheldon lock --update
