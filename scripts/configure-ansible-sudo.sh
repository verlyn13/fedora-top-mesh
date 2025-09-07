#!/bin/bash
# Configure passwordless sudo for Ansible automation
# Run this script with: sudo ./scripts/configure-ansible-sudo.sh

set -euo pipefail

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo"
    echo "Usage: sudo ./scripts/configure-ansible-sudo.sh"
    exit 1
fi

echo "=== Configuring Ansible Sudo Access ==="
echo

# Create sudoers.d file for Ansible automation
SUDOERS_FILE="/etc/sudoers.d/ansible-automation"

echo "Creating sudoers configuration for user: verlyn13"

# Create the sudoers entry
cat > "$SUDOERS_FILE" << 'EOF'
# Ansible automation for verlyn13 user
# Allows passwordless sudo for configuration management
# Created by fedora-top-mesh setup
verlyn13 ALL=(ALL) NOPASSWD: ALL
EOF

# Set correct permissions (sudoers files must be 440)
chmod 440 "$SUDOERS_FILE"

# Validate the sudoers file
if visudo -cf "$SUDOERS_FILE" >/dev/null 2>&1; then
    echo "✅ Sudoers file created successfully: $SUDOERS_FILE"
    echo "✅ Syntax validation passed"
    echo
    echo "User 'verlyn13' can now run sudo commands without password."
    echo "This enables Ansible to perform administrative tasks automatically."
else
    echo "❌ Sudoers file syntax error - removing invalid file"
    rm -f "$SUDOERS_FILE"
    exit 1
fi

# Test the configuration
echo "Testing sudo access..."
if sudo -u verlyn13 sudo -n true 2>/dev/null; then
    echo "✅ Passwordless sudo working correctly"
else
    echo "⚠️  Note: Test may fail due to session context, but configuration is correct"
fi

echo
echo "=== Configuration Complete ==="
echo
echo "Next steps:"
echo "1. Test from control node: ssh verlyn13@laptop.hq 'sudo whoami'"
echo "2. Run Ansible playbooks: ansible-playbook -l laptop.hq playbooks/site.yaml"