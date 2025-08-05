function gwtc() {
  # Check if the first and second arguments are provided
  if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo "Usage: gwtc <repository-url> <directory>"
    echo "Clones a bare repository and initializes a worktree structure."
    return 1
  fi

  mkdir -p "$2/worktrees"
  git clone --bare "$1" "$2/repo.git"
  git --git-dir="$2/repo.git" worktree add "$2/worktrees/main" main
}

function _gwt_ascertain() {
  local repo=""
  local worktrees=""
  if [ -d "repo.git" ]; then
    repo="$(pwd)/repo.git"
    worktrees="$(pwd)/worktrees"
  elif [ -d "../repo.git" ] && [ "$(basename "$(pwd)")" = "worktrees" ]; then
    repo="$(pwd)/../repo.git"
    worktrees="$(pwd)"
  elif [ "$(basename "$(pwd)")" = "repo.git" ]; then
    repo="$(pwd)"
    worktrees="$(pwd)/../worktrees"
  elif [ -f ".git" ]; then
    # Parse out the gitdir from .git file.
    repo="$(cat .git | sed 's|^gitdir: ||')"
    # Drop the trailing worktree path from the gitdir
    repo="${repo%/worktrees/*}"
    worktrees="$(dirname "$repo")/worktrees"
  else
    echo "Error: Could not ascertain git repository location." >&2
    echo ""
    return
  fi

  repo="$(realpath "$repo")"
  worktrees="$(realpath "$worktrees")"

  if [ ! -d "$worktrees" ]; then
    echo "Error: worktrees directory '$worktrees' does not exist." >&2
    echo ""
    return
  fi

  printf "%s;%s\n" "$repo" "$worktrees"
}

function gwt() {
  # Check if the first argument is provided
  if [[ -z "$1" ]]; then
    echo "Usage: gwt <branch-name>"
    echo "Creates a new worktree for the specified branch."
    return 1
  fi

  local result=$(_gwt_ascertain || return 1)
  if [[ -z $result ]]; then
    return 1
  fi

  IFS=';' read repo worktrees <<< "$result"
  echo "Creating worktree: ${worktrees}/$1"
  git --git-dir=${repo} worktree add "${worktrees}/$1" "$1"
}

function gwtr() {
  # Check if the first argument is provided
  if [[ -z "$1" ]]; then
    echo "Usage: gwtr <branch-name>"
    echo "Removes the specified worktree."
    return 1
  fi

  local result=$(_gwt_ascertain)
  if [[ -z $result ]]; then
    return 1
  fi

  IFS=';' read repo worktrees <<< "$result"
  echo "Removing worktree: ${worktrees}/$1"
  git --git-dir=${repo} worktree remove "${worktrees}/$1"
}
