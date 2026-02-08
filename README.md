# dotfiles

Minimal dotfiles managed with [`just`](https://github.com/casey/just).

## Prerequisites

- macOS
- Git
- [Homebrew](https://brew.sh) (installed automatically by `just setup` if missing)

## Quickstart

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
just setup
exec zsh
```

`just setup` runs these steps in order:

1. **backup** — moves `~/.dotfiles` to `~/.dotfiles.bak` (if it exists)
2. **brew** — installs Homebrew if missing, then installs packages from `Brewfile`
3. **symlinks** — links config files into place (backs up existing files to `.bak`)
4. **gitconfig-setup** — splits `~/.gitconfig` into private values + shared include
5. **shell** — sets zsh as default shell

## File Structure

```
~/dotfiles/
  Brewfile              # Homebrew CLI tools + fonts
  justfile              # setup orchestrator
  zshrc                 # -> ~/.zshrc
  gitconfig             # included by ~/.gitconfig via [include]
  gitignore             # global gitignore (referenced by gitconfig)
  claude/               # -> ~/.claude
    settings.json       # Claude Code preferences
  config/
    nvim/               # -> ~/.config/nvim
    sheldon/            # -> ~/.config/sheldon
    starship.toml       # -> ~/.config/starship.toml
    ghostty/            # -> ~/.config/ghostty
    lazygit/            # -> ~/.config/lazygit
```

## Symlink Map

| Source | Target |
|--------|--------|
| `zshrc` | `~/.zshrc` |
| `claude/` | `~/.claude` |
| `config/*/` | `~/.config/*/` |
| `config/starship.toml` | `~/.config/starship.toml` |

## Gitconfig

Git configuration is split into two files:

- **`~/.gitconfig`** — private values only (user.name, email, GPG signing)
- **`~/dotfiles/gitconfig`** — shared settings, aliases, URL shorthands (included via `[include]`)

This keeps secrets out of the repo. The `just gitconfig-setup` recipe handles the migration automatically.

## Other Commands

```bash
just symlinks   # re-run symlinks only
just update     # update brew packages + sheldon plugins
```

## Adding New Configs

Drop a directory into `config/` and run `just symlinks` — it will automatically be linked to `~/.config/`.

## Backup

The old `~/.dotfiles` repo (Dotbot + zgen + Oh-My-Zsh) is preserved at `~/.dotfiles.bak`. It is not deleted.
