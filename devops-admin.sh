#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
BACKUP_DIR="$SCRIPT_DIR/backups"
LOG_FILE="$LOG_DIR/admin-tool.log"

log_message() {
  local message="$1"
  mkdir -p "$LOG_DIR"
  echo "$(date '+%Y-%m-%d %H:%M:%S') | user=${SUDO_USER:-$(whoami)} | $message" >> "$LOG_FILE"
}

error_exit() {
  echo "Error: $1" >&2
  log_message "ERROR: $1"
  exit 1
}

require_root() {
  [[ $EUID -eq 0 ]] || error_exit "Run this command with sudo."
}

validate_name() {
  local name="$1"

  [[ "$name" =~ ^[a-z][a-z0-9_-]{2,31}$ ]] ||
    error_exit "Name must start with a lowercase letter and use 3-32 lowercase letters, numbers, hyphens, or underscores."
}

user_exists() {
  id "$1" &>/dev/null
}

group_exists() {
  getent group "$1" &>/dev/null
}

create_user() {
  local username="$1"

  require_root
  validate_name "$username"

  user_exists "$username" && error_exit "User '$username' already exists."

  useradd -m -s /bin/bash "$username"
  log_message "Created user '$username'"
  echo "Success: User '$username' was created."
}

delete_user() {
  local username="$1"
  local confirmation

  require_root
  validate_name "$username"

  user_exists "$username" || error_exit "User '$username' does not exist."

  [[ "$username" != "root" && "$username" != "ubuntu" ]] ||
    error_exit "Refusing to delete protected account '$username'."

  read -r -p "Delete '$username' and their home directory? Type YES to continue: " confirmation
  [[ "$confirmation" == "YES" ]] || error_exit "Deletion cancelled."

  userdel -r "$username"
  log_message "Deleted user '$username' and home directory"
  echo "Success: User '$username' was deleted."
}

change_user_shell() {
  local username="$1"
  local shell_path="$2"

  require_root
  user_exists "$username" || error_exit "User '$username' does not exist."
  [[ -x "$shell_path" ]] || error_exit "Shell '$shell_path' does not exist or is not executable."

  usermod -s "$shell_path" "$username"
  log_message "Changed shell for '$username' to '$shell_path'"
  echo "Success: Shell updated for '$username'."
}

create_group() {
  local groupname="$1"

  require_root
  validate_name "$groupname"

  group_exists "$groupname" && error_exit "Group '$groupname' already exists."

  groupadd "$groupname"
  log_message "Created group '$groupname'"
  echo "Success: Group '$groupname' was created."
}

add_user_to_group() {
  local username="$1"
  local groupname="$2"

  require_root
  user_exists "$username" || error_exit "User '$username' does not exist."
  group_exists "$groupname" || error_exit "Group '$groupname' does not exist."

  usermod -aG "$groupname" "$username"
  log_message "Added user '$username' to group '$groupname'"
  echo "Success: Added '$username' to '$groupname'."
}

list_users() {
  echo "Regular Linux users:"
  getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {printf "%-20s UID: %s  Home: %s\n", $1, $3, $6}'
}

list_groups() {
  echo "Regular Linux groups:"
  getent group | awk -F: '$3 >= 1000 {printf "%-20s GID: %s  Members: %s\n", $1, $3, $4}'
}

backup_directory() {
  local input_directory="$1"
  local source_directory
  local archive_name
  local archive_path

  [[ -d "$input_directory" ]] || error_exit "Directory '$input_directory' does not exist."

  source_directory="$(readlink -f "$input_directory")"
  mkdir -p "$BACKUP_DIR"

  archive_name="$(basename "$source_directory")_$(date '+%Y%m%d_%H%M%S').tar.gz"
  archive_path="$BACKUP_DIR/$archive_name"

  tar -czf "$archive_path" -C "$(dirname "$source_directory")" "$(basename "$source_directory")"

  log_message "Created backup '$archive_name' from '$source_directory'"
  echo "Success: Backup created at $archive_path"
}

show_system_info() {
  echo "Hostname: $(hostname)"
  echo "Operating system: $(. /etc/os-release && echo "$PRETTY_NAME")"
  echo "Kernel: $(uname -r)"
  echo "Uptime: $(uptime -p)"
  echo "Disk usage:"
  df -h / | tail -n 1
}

show_usage() {
  cat <<'EOF'
Linux User Management and Directory Backup Tool

Usage:
  sudo ./devops-admin.sh create-user <username>
  sudo ./devops-admin.sh delete-user <username>
  sudo ./devops-admin.sh change-shell <username> <shell-path>
  sudo ./devops-admin.sh create-group <groupname>
  sudo ./devops-admin.sh add-to-group <username> <groupname>
       ./devops-admin.sh list-users
       ./devops-admin.sh list-groups
       ./devops-admin.sh backup <directory-path>
       ./devops-admin.sh system-info
       ./devops-admin.sh help
EOF
}

case "${1:-help}" in
  create-user)
    [[ -n "${2:-}" ]] || error_exit "Username is required."
    create_user "$2"
    ;;
  delete-user)
    [[ -n "${2:-}" ]] || error_exit "Username is required."
    delete_user "$2"
    ;;
  change-shell)
    [[ -n "${2:-}" && -n "${3:-}" ]] || error_exit "Username and shell path are required."
    change_user_shell "$2" "$3"
    ;;
  create-group)
    [[ -n "${2:-}" ]] || error_exit "Group name is required."
    create_group "$2"
    ;;
  add-to-group)
    [[ -n "${2:-}" && -n "${3:-}" ]] || error_exit "Username and group name are required."
    add_user_to_group "$2" "$3"
    ;;
  list-users)
    list_users
    ;;
  list-groups)
    list_groups
    ;;
  backup)
    [[ -n "${2:-}" ]] || error_exit "Directory path is required."
    backup_directory "$2"
    ;;
  system-info)
    show_system_info
    ;;
  help|--help|-h)
    show_usage
    ;;
  *)
    error_exit "Unknown command '$1'. Run './devops-admin.sh help'."
    ;;
esac
