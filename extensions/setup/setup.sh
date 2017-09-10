#!/bin/bash
set -e

COLOR_END='\e[0m'
COLOR_RED='\e[0;31m'
COLOR_YEL='\e[0;33m'

# This current directory.
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$DIR/../../" && pwd)
EXTERNAL_ROLE_DIR="$ROOT_DIR/roles/external"
ROLES_REQUIREMENTS_FILE="$ROOT_DIR/roles/roles_requirements.yml"

msg_exit() {
    printf "$COLOR_RED$@$COLOR_END"
    printf "\n"
    printf "Exiting...\n"
    exit 1
}

msg_warning() {
    printf "$COLOR_YEL$@$COLOR_END"
    printf "\n"
}

# Trap if ansible-galaxy failed and warn user
cleanup() {
    msg_exit "Update failed. Please don't commit or push roles till you fix the issue"
}
trap "cleanup"  ERR INT TERM


# Check if not root
[[ "$(whoami)" == "root" ]] && msg_exit "Please run as a normal user not root"

# Check ansible-galaxy
[[ -z "$(which ansible-galaxy)" ]] && msg_exit "Ansible is not installed or not in your path."

# Check roles req file
[[ ! -f "$ROLES_REQUIREMENTS_FILE" ]] && msg_exit "roles_requirements '$ROLES_REQUIREMENTS_FILE' does not exist or access issue.\nPlease check and re-run."

# Remove existing roles
if [ -d "$EXTERNAL_ROLE_DIR" ]; then
    cd "$EXTERNAL_ROLE_DIR"
	if [ "$(pwd)" == "$EXTERNAL_ROLE_DIR" ];then
	  echo "Removing current roles in '$EXTERNAL_ROLE_DIR/*'"
	  rm -rf *
	else
	  msg_exit "Path error could not change dir to $EXTERNAL_ROLE_DIR"
	fi
fi


# Install roles
ansible-galaxy install -r "$ROLES_REQUIREMENTS_FILE" --force --no-deps -p "$EXTERNAL_ROLE_DIR"


#Touch vpass
echo "Touching vpass"
if [ -w "$ROOT_DIR" ]
then
   touch "$ROOT_DIR/.vpass"
else
  sudo touch "$ROOT_DIR/.vpass"
fi

exit 0
