#!/usr/bin/env bash
# WorktreeCreate / WorktreeRemove hook: keep Claude Code worktrees in
# ~/.cache/claude-worktrees/<repo>/<name> instead of <repo>/.claude/worktrees,
# so repo-wide tools (yamllint etc.) don't scan them.
#
# Mirrors Claude Code's default git behavior: branch worktree-<name> from
# origin/HEAD (falling back to HEAD), reuse an existing directory by name.
# Repos with a bin/worktree-env get the worktree's own databases, Redis
# database and ports on create, and lose them again on remove.
# Only the worktree path goes to stdout; everything else goes to stderr.
set -euo pipefail

ROOT="${CLAUDE_WORKTREE_ROOT:-${XDG_CACHE_HOME:-$HOME/.cache}/claude-worktrees}"
input=$(cat)

create() {
  local name cwd common main repo dir branch base
  name=$(jq -r '.name' <<<"$input")
  cwd=$(jq -r '.cwd' <<<"$input")

  common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)
  main=$(dirname "$common")
  repo=$(basename "$main")
  dir="$ROOT/$repo/$name"
  branch="worktree-$name"

  if [[ -d $dir ]]; then
    echo "$dir"
    return
  fi

  # Drop git's records of worktree directories deleted by hand.
  git -C "$main" worktree prune >&2
  mkdir -p "$ROOT/$repo"

  if git -C "$main" rev-parse --verify -q "refs/heads/$branch" >/dev/null; then
    git -C "$main" worktree add "$dir" "$branch" >&2
  else
    base=$(git -C "$main" rev-parse --verify -q origin/HEAD || git -C "$main" rev-parse HEAD)
    git -C "$main" worktree add -b "$branch" "$dir" "$base" >&2
  fi

  # A failed setup still leaves a usable worktree; the session can rerun it.
  if [[ -x $dir/bin/worktree-env ]]; then
    (cd "$dir" && bin/worktree-env setup) >&2 ||
      echo "worktree.sh: bin/worktree-env setup failed; run it again in $dir" >&2
  fi

  echo "$dir"
}

remove() {
  local path main branch
  path=$(jq -r '.worktree_path' <<<"$input")
  [[ -d $path ]] || return 0

  main=$(dirname "$(git -C "$path" rev-parse --path-format=absolute --git-common-dir)")
  branch=$(git -C "$path" symbolic-ref -q --short HEAD || true)

  if [[ -x $path/bin/worktree-env ]]; then
    (cd "$path" && bin/worktree-env drop) >&2 ||
      echo "worktree.sh: bin/worktree-env drop failed; bin/worktree-env prune cleans up later" >&2
  fi

  # Claude Code has already confirmed removal with the user if the worktree
  # had changes or commits, matching its default `git worktree remove`.
  git -C "$main" worktree remove --force "$path" >&2
  if [[ $branch == worktree-* ]]; then
    git -C "$main" branch -D "$branch" >&2
  fi
}

case "${1:-}" in
  create) create ;;
  remove) remove ;;
  *) echo "usage: $0 create|remove" >&2; exit 1 ;;
esac
