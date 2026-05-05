#!/bin/sh
# Git sync script for Obsidian vault on a-Shell (iOS)
# Uses lg2 (libgit2) instead of git

GIT_CONFIG_USER_NAME="<YOUR_GIT_USER_NAME>"
GIT_CONFIG_USER_EMAIL="<YOUR_GIT_EMAIL>"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'

print_msg() {
	printf "%b\n" "$1"
}

ORIGINAL_DIR=$(pwd)

	SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
	VAULT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
	VAULT_NAME="$(basename "$VAULT_DIR")"

	print_msg "${YELLOW}Starting git sync for the vault \"${VAULT_NAME}\" on a-Shell...${NO_COLOR}"

	cd "$VAULT_DIR" || {
		print_msg "${RED}Error: Could not navigate to vault directory${NO_COLOR}"
			exit 1
	}

if [ ! -d ".git" ]; then
print_msg "${RED}Error: Not a git repository${NO_COLOR}"
cd "$ORIGINAL_DIR"
exit 1
fi

# Check if any SSH key exists
SSH_KEY_PATH=""
for key_type in id_ed25519 id_rsa id_ecdsa id_dsa; do
if [ -f "$HOME/Documents/.ssh/${key_type}.pub" ]; then
SSH_KEY_PATH="$HOME/Documents/.ssh/${key_type}"
break
fi
done

if [ -z "$SSH_KEY_PATH" ]; then
print_msg "${RED}Error: No SSH keypair found in $HOME/Documents/.ssh/${NO_COLOR}"
print_msg "${YELLOW}Please generate an SSH key pair first:${NO_COLOR}"
print_msg "  ssh-keygen -t ed25519 -C \"$GIT_CONFIG_USER_EMAIL\""
cd "$ORIGINAL_DIR"
exit 1
fi

# Configure lg2 if not already set
if [ -z "$(lg2 config user.name 2>/dev/null)" ]; then
lg2 config user.name "$GIT_CONFIG_USER_NAME" 2>/dev/null || true
fi

if [ -z "$(lg2 config user.email 2>/dev/null)" ]; then
lg2 config user.email "$GIT_CONFIG_USER_EMAIL" 2>/dev/null || true
fi

if [ -z "$(lg2 config user.identityFile 2>/dev/null)" ]; then
lg2 config user.identityFile "$SSH_KEY_PATH" 2>/dev/null || true

lg2 config user.password "" 2>/dev/null || true
print_msg "${YELLOW}Note: user.password set to empty. Change it if your SSH key has a passphrase.${NO_COLOR}"
fi

get_timestamp() {
	date +"%Y.%m.%d %H:%M:%S"
}

	HOSTNAME="a-Shell on iOS"
TIMESTAMP=$(get_timestamp)
	COMMIT_MSG="Update vault from ${HOSTNAME} (${TIMESTAMP})"

	print_msg "${YELLOW}Checking status...${NO_COLOR}"

	if [ -z "$(lg2 status --porcelain)" ]; then
	print_msg "${GREEN}No local changes to commit${NO_COLOR}"
	else
	print_msg "${YELLOW}Local changes detected, staging files...${NO_COLOR}"
	lg2 add .

	print_msg "${YELLOW}Committing changes...${NO_COLOR}"
	if ! lg2 commit -m "$COMMIT_MSG"; then
	print_msg "${RED}Error: Commit failed${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi
	print_msg "${GREEN}Changes committed successfully${NO_COLOR}"
	fi

	if ! lg2 remote show origin --verbose >/dev/null 2>&1; then
	print_msg "${RED}Error: No remote 'origin' configured${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi

	print_msg "${YELLOW}Pulling changes from remote...${NO_COLOR}"

# When local and remote branches are in a diverged state, `lg2 pull` fails to do a fast-forward
# merge, even though the history allows it. Using fetch + merge explicitly handles this.
#
# Divergent branch scenario:
#    Remote: A---B---C---D (origin/main)
#                     \
#    Local:            E---F (main, HEAD)
#
# After fetch + merge --no-commit, a fast-forward merge is performed:
#    Result: A---B---C---D---E---F (main, HEAD)
#                                  (origin/main)
#
# This is what `lg2 pull` should do but doesn't, so we do it manually.

	if ! lg2 fetch origin; then
	print_msg "${RED}Error: Fetch failed${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi

	if ! lg2 merge --no-commit origin; then
	print_msg "${RED}Error: Merge failed. You may need to resolve conflicts.${NO_COLOR}"
	print_msg "${YELLOW}Run 'lg2 status' to see what needs attention${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi

	print_msg "${GREEN}Pull (fetch + merge) completed successfully${NO_COLOR}"

LOCAL=$(lg2 rev-parse refs/heads/main 2>/dev/null)
	REMOTE=$(lg2 rev-parse refs/remotes/origin/main 2>/dev/null || echo "")

	if [ -z "$REMOTE" ]; then
	print_msg "${YELLOW}No upstream branch set, pushing to origin...${NO_COLOR}"
	if ! lg2 push origin; then
	print_msg "${RED}Error: Push failed${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi
	print_msg "${GREEN}Push completed successfully${NO_COLOR}"
	elif [ "$LOCAL" != "$REMOTE" ]; then
	print_msg "${YELLOW}Pushing changes to remote...${NO_COLOR}"
	if ! lg2 push origin; then
	print_msg "${RED}Error: Push failed${NO_COLOR}"
	cd "$ORIGINAL_DIR"
	exit 1
	fi
	print_msg "${GREEN}Push completed successfully${NO_COLOR}"
	else
	print_msg "${GREEN}Already up to date with remote${NO_COLOR}"
	fi

	cd "$ORIGINAL_DIR"

	print_msg "${GREEN}✓ Git sync completed successfully${NO_COLOR}"
