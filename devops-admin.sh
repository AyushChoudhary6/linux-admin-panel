#!/usr/bin/env bash

set -u

LOG_FILE="logs/admin-tool.log"

log_message() {
  local message="$1"
  mkdir -p logs
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: Run this command with sudo."
    exit 1
  fi
}

validate_username() {
  local username="$1"

  if [[ ! "$username" =~ ^[a-z][a-z0-9_-]{2,31}$ ]]; then
    echo "Error: Username must begin with a lowercase letter and contain 3-32 lowercase letters, numbers, hyphens, or underscores."
    exit 1
  fi
}

create_user() {
  local username="$1"

  require_root
  validate_username "$username"

  if id "$username" &>/dev/null; then
    echo "Error: User '$username' already exists."
    exit 1
  fi

  useradd -m -s /bin/bash "$username"
  log_message "Created user: $username"

  echo "Success: User '$username' was created."
}

show_usage() {
  echo "Usage: sudo ./devops-admin.sh create-user <username>"
}

case "${1:-}" in
  create-user)
    if [[ -z "${2:-}" ]]; then
      show_usage
      exit 1
    fi
    create_user "$2"
    ;;
  *)
    show_usage
    ;;
esac
