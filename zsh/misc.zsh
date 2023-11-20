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
