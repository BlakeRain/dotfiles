function zsh_stats() {
  fc -l 1 \
    | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
    | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}

function new_fernet_key() {
  python3 -c "import random; import base64; print(base64.urlsafe_b64encode(bytes(random.choices(range(255), k=32))).decode('utf-8'))"
}

function new_password() {
  if [ -z "$1" ]; then
    echo "Usage: new_password <length>"
    return 1
  fi

  python3 -c "import random; import string; print(''.join(random.choices(string.ascii_letters + string.digits, k=$1)))"
}

function new_ssh_key() {
  if [ -z "$1" ]; then
    echo "Usage: new_ssh_key <email>"
    return 1
  fi

  ssh-keygen -t ed25519 -C "$1"
}

function enc_dir() {
  # Make sure that we get a directory as an argument.
  if [ -z "$1" ]; then
    echo "Usage: enc_dir <dir>"
    return 1
  fi

  # Make sure that the directory exists.
  if [ ! -d "$1" ]; then
    echo "Directory does not exist: $1"
    return 1
  fi

  # We're going to use a temporary file, just in case the directory in '$1' is
  # the same as the directory that we're in. After encrypting to the temporary file
  # we can then move it back in place.
  local temp_file="$(mktemp)"
  tar -cz "$1" | gpg --encrypt --output "$temp_file" --yes
  mv "$temp_file" "$(basename "$1").tar.gz.gpg"
}

function enc_cwd() {
  # Because we can't create the encrypted file in the same directory that we are
  # encrypting, we need to first create the file in the temporary directory and
  # then move it into the current working directory with the correct name.
  local temp_file="$(mktemp)"
  tar -cz . | gpg --encrypt --output "$temp_file" --yes
  mv "$temp_file" "$(basename "$(pwd)").tar.gz.gpg"
}
