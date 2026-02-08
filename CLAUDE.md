# Dotfiles Repo

## Structure

- `config/*` directories are symlinked to `~/.config/*` by `just symlinks`
- `config/starship.toml` is a file symlink (special case, not a directory)
- `zshrc` is symlinked to `~/.zshrc`
- `claude/` is symlinked to `~/.claude`
- `gitconfig` is NOT symlinked — it's included by `~/.gitconfig` via `[include] path`
- `gitignore` is the global gitignore, referenced by `gitconfig` via `core.excludesfile`

## Rules

- **justfile must stay idempotent** — all recipes are safe to run multiple times
- **gitconfig split**: private values (user.name, email, GPG) live in `~/.gitconfig`, shared settings live in `~/dotfiles/gitconfig`
- **sheldon** is the zsh plugin manager — no Oh-My-Zsh, no zgen
- **zshrc should stay minimal** — ~30 lines, no framework boilerplate
- **No desktop casks in Brewfile** — CLI tools and fonts only
- **No Oh-My-Zsh** — this repo intentionally replaces it

## Adding a new config

1. Create `config/<tool>/` with config files
2. Run `just symlinks` — the loop picks it up automatically
3. No justfile changes needed
