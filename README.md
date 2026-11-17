# dotfiles

```sh
./install   # link everything into $HOME, merge the Claude Code settings
```

`install` symlinks each file into place, so editing `~/.zshrc` edits this
repo. A file already in place is moved to `<file>.backup` first. Running it
again is safe.

It needs `jq`. The configs expect oh-my-zsh, rbenv, nvm, Neovim, diff-so-fancy
and the GitHub CLI.

## What goes where

| Repo                           | Linked as                                      |
| ------------------------------ | ---------------------------------------------- |
| `.zshrc`, `.aliases`           | `~/.zshrc`, `~/.aliases`                       |
| `.gitconfig`                   | `~/.gitconfig`                                 |
| `.gitignore_global`            | `~/.gitignore_global`                          |
| `.vimrc`                       | `~/.vimrc`                                     |
| `config/gh/config.yml`         | `~/.config/gh/config.yml`                      |
| `agents/AGENTS.md`             | `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md` |
| `claude/hooks/worktree.sh`     | `~/.claude/hooks/worktree.sh`                  |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh`              |

`claude/settings.json` isn't linked: Claude Code rewrites its settings file,
so `install` merges the hooks and status line into `~/.claude/settings.json`.

## Kept out of this repo

The repo is public. Machine- and work-specific setup goes in files that
aren't tracked here:

- `~/.zshrc.local`, sourced by `.zshrc`
- `~/.zshenv`, for variables non-interactive shells need too

Credentials stay out entirely, e.g. `~/.bundle/config`, `~/.netrc`, `~/.aws`,
`~/.ssh` and gh's `hosts.yml`.

## Agents

`agents/AGENTS.md` holds the global instructions for every coding agent, so
Codex and Claude Code follow the same rules.

`claude/hooks/worktree.sh` keeps Claude Code worktrees in
`~/.cache/claude-worktrees/<repo>/<name>` instead of inside the repo. In repos
with a `bin/worktree-env`, each worktree also gets its own databases, Redis
database and ports, set up on create and dropped on remove.

`claude/statusline-command.sh` shows `user@host:dir` as the status line.
