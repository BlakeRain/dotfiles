#autoload

# opswd puts the password of the named service into the clipboard. If there's a
# one time password, it will be copied into the clipboard after 10 seconds. The
# clipboard is cleared after another 20 seconds.
function opswd() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: opswd <service>"
    return 1
  fi

  local service=$1

  # If not logged in, print error and return
  op user list > /dev/null || return

  local username
  # Copy the username to the clipboard
  if ! username=$(op item get "$service" --fields username 2>/dev/null); then
    echo "error: could not obtain username for $service"
    return 1
  fi

  echo -n "$username" | pbcopy
  echo -n "✔ username for service $service copied to the clipboard. Press Enter to continue"
  read

  local password
  # Copy the password to the clipboard
  if ! password=$(op item get "$service" --fields password 2>/dev/null); then
    echo "error: could not obtain password for $service"
    return 1
  fi

  echo -n "$password" | pbcopy
  echo -n "✔ password for $service copied to clipboard. Press Enter to continue"
  read

  # If there's a one time password, copy it to the clipboard
  local totp
  if totp=$(op item get --otp "$service" 2>/dev/null) && [[ -n "$totp" ]]; then
    echo -n "$totp" | pbcopy
    echo "✔ TOTP for $service copied to clipboard"
  else
    echo "✔ No TOTP stored 😄"
  fi


  (sleep 20 && pbcopy </dev/null 2>/dev/null) &!
}

function ghtoken() {
  op item get "GitHub (BlakeRain)" --fields "CLI PAT"
}
