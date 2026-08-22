# Linux User Management and Directory Backup Tool

A Bash-based Linux administration automation tool built and tested on an Ubuntu AWS EC2 instance. The project automates common user and group management tasks, creates compressed directory backups, validates input, and records administrative activity in logs.

This project demonstrates foundational DevOps skills including Linux administration, Bash scripting, AWS EC2, permissions, backups, logging, Git, and GitHub.

## Features

- Create Linux users with a home directory and Bash shell
- Delete users and their home directories with confirmation
- Change a user’s login shell
- Create Linux groups
- Add users to supplementary groups
- List regular Linux users and groups
- Create compressed `.tar.gz` directory backups
- Display basic system information
- Validate user and group names
- Check whether users and groups already exist
- Require `sudo` for privileged operations
- Log administrative actions with timestamps
- Provide command-line help and error messages

## Technologies Used

- Ubuntu Linux
- AWS EC2
- Bash
- Linux user and group management commands
- `tar` and `gzip`
- Git and GitHub

## Project Structure

```text
linux-admin-tool/
├── devops-admin.sh       # Main Bash automation script
├── README.md             # Project documentation
├── .gitignore            # Excludes generated files from Git
├── backups/              # Generated compressed backups
├── logs/                 # Script activity logs
└── docs/                 # Optional screenshots and project documentation
```

## Prerequisites

- Ubuntu Linux system or Ubuntu AWS EC2 instance
- Bash
- `sudo` access
- Git, if you want to version-control and publish the project

Check that Git is installed:

```bash
git --version
```

Install it if necessary:

```bash
sudo apt update
sudo apt install -y git
```

## Installation

Clone the repository:

```bash
git clone <your-github-repository-url>
cd linux-admin-tool
```

Make the script executable:

```bash
chmod +x devops-admin.sh
```

Check the script syntax before running it:

```bash
bash -n devops-admin.sh
```

If the command produces no output, the Bash syntax is valid.

## Usage

Display all available commands:

```bash
./devops-admin.sh help
```

### Create a User

```bash
sudo ./devops-admin.sh create-user <username>
```

Example:

```bash
sudo ./devops-admin.sh create-user devopsdemo1
```

This creates:

- A Linux user named `devopsdemo1`
- A home directory at `/home/devopsdemo1`
- A default Bash login shell

Verify the user:

```bash
id devopsdemo1
ls -ld /home/devopsdemo1
```

### Delete a User

```bash
sudo ./devops-admin.sh delete-user <username>
```

Example:

```bash
sudo ./devops-admin.sh delete-user devopsdemo1
```

The script requires you to type `YES` before deletion. It removes both the user account and their home directory.

For safety, the script refuses to delete the `root` and `ubuntu` accounts.

### Change a User Shell

```bash
sudo ./devops-admin.sh change-shell <username> <shell-path>
```

Example:

```bash
sudo ./devops-admin.sh change-shell devopsdemo1 /bin/bash
```

The script verifies that the specified shell exists and is executable.

### Create a Group

```bash
sudo ./devops-admin.sh create-group <groupname>
```

Example:

```bash
sudo ./devops-admin.sh create-group devops-team
```

Verify the group:

```bash
getent group devops-team
```

### Add a User to a Group

```bash
sudo ./devops-admin.sh add-to-group <username> <groupname>
```

Example:

```bash
sudo ./devops-admin.sh add-to-group devopsdemo1 devops-team
```

Verify membership:

```bash
id devopsdemo1
```

The script uses `usermod -aG`. The `-a` option appends the group membership and prevents existing supplementary groups from being removed.

### List Users

```bash
./devops-admin.sh list-users
```

This displays regular Linux user accounts with their username, UID, and home directory.

### List Groups

```bash
./devops-admin.sh list-groups
```

This displays regular Linux groups with their group ID and members.

### Back Up a Directory

```bash
./devops-admin.sh backup <directory-path>
```

Example:

```bash
./devops-admin.sh backup /home/ubuntu/linux-admin-tool
```

The script creates a timestamped compressed archive in the `backups/` directory.

Example output:

```text
backups/linux-admin-tool_20260822_120000.tar.gz
```

View generated backups:

```bash
ls -lh backups/
```

Inspect an archive without extracting it:

```bash
tar -tzf backups/<backup-file-name>.tar.gz
```

Extract an archive:

```bash
mkdir restored-backup
tar -xzf backups/<backup-file-name>.tar.gz -C restored-backup
```

### Show System Information

```bash
./devops-admin.sh system-info
```

This displays:

- Hostname
- Ubuntu version
- Kernel version
- System uptime
- Root disk usage

## Logging

Administrative actions are written to:

```text
logs/admin-tool.log
```

View the latest activity:

```bash
sudo tail -n 20 logs/admin-tool.log
```

Example log entry:

```text
2026-08-22 12:00:00 | user=ubuntu | Created user 'devopsdemo1'
```

## Input Validation and Safety

The script applies several safeguards:

- User and group names must begin with a lowercase letter.
- Names may contain lowercase letters, numbers, hyphens, and underscores.
- User and group names must be between 3 and 32 characters.
- Privileged operations require `sudo`.
- The script checks for existing users and groups before creation.
- The script checks that a user or group exists before modifying it.
- User deletion requires explicit confirmation.
- The `root` and `ubuntu` accounts cannot be deleted.
- Errors are recorded in the activity log.

## Testing Checklist

Run the following commands to test the project safely:

```bash
bash -n devops-admin.sh

sudo ./devops-admin.sh create-user devopsdemo1
sudo ./devops-admin.sh create-group devops-team
sudo ./devops-admin.sh add-to-group devopsdemo1 devops-team

id devopsdemo1
getent group devops-team

./devops-admin.sh list-users
./devops-admin.sh list-groups
./devops-admin.sh system-info

./devops-admin.sh backup /home/ubuntu/linux-admin-tool
ls -lh backups/

sudo tail -n 20 logs/admin-tool.log
```

Optional cleanup after testing:

```bash
sudo ./devops-admin.sh delete-user devopsdemo1
sudo groupdel devops-team
```

## Git and GitHub

Initialize Git if you have not already:

```bash
git init -b main
git add .
git commit -m "Build Linux administration and backup automation tool"
```

Connect your GitHub repository:

```bash
git remote add origin <your-github-repository-url>
git push -u origin main
```

Check repository status at any time:

```bash
git status
```

## Future Improvements

- Add an interactive menu-driven interface
- Add password configuration for newly created users
- Add a dry-run mode for potentially destructive commands
- Add a backup retention policy
- Add automated tests with ShellCheck
- Add email or Slack notifications for backup success/failure
- Schedule backups using `cron`
- Add support for restoring backups through the script
- Containerize the tool for isolated local testing

## Portfolio Summary

Built and tested a Bash-based Linux administration automation tool on an Ubuntu AWS EC2 instance. The project automates user and group management, validates administrator input, creates timestamped compressed backups, logs administrative actions, and uses Git/GitHub for version control.

## Author

Your Name  
GitHub: [Your GitHub Profile](https://github.com/your-username)
