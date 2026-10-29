# dotfiles

```sh
./install            # link the dotfiles and Claude Code hooks, merge Claude settings
claude-agent/setup   # create the isolated claude-agent user (uses sudo)
```

## Claude Code

`claude/hooks/worktree.sh` keeps Claude Code worktrees in
`~/.cache/claude-worktrees/<repo>/<name>`. In repos with a `bin/worktree-env`,
each worktree also gets its own databases, Redis database and ports, set up on
create and dropped on remove.

## claude-agent

`claude-agent/setup` creates a `claude-agent` user that runs Claude Code
without access to your credentials:

- It can't read your home directory (AWS SSO cache, SSH keys, `~/.netrc`,
  browser profiles), and a firewall rule keeps it off your own Postgres and
  Redis ports.
- It has its own clones of the checkouts listed in
  `~/.config/claude-agent/repos`, its own Postgres and Redis (`compose.yml`,
  ports 5436 and 6393, seed and test data only), and Playwright MCP for
  headless Chrome and Firefox.
- Its AWS config has only the read-only profiles, under an SSO session it
  signs in to as its own Identity Center user. It uses your GitHub token and
  has no Heroku credentials.

Start it from one of your checkouts with `claude-agent`. Arguments go to
`claude`, e.g. `claude-agent -w review`. Its commits reach your checkout with
`git fetch agent`.
