function gwt() {
  # Check if the first argument is provided
  if [[ -z "$1" ]]; then
    echo "Usage: gwt <branch-name>"
    return 1
  fi

  git --git-dir=repo.git worktree add "worktrees/$1" "$1"
}
