#!/bin/bash
# Accept SSH key from Ansible control node
# This authorizes the control node to manage this laptop

set -euo pipefail

CONTROL_NODE="hetzner-hq"
CONTROL_IP="100.84.151.58"
KEY_NAME="ansible_ed25519"

echo "=== Accepting Ansible Control Node SSH Key ==="
echo
echo "This script will authorize the control node (${CONTROL_NODE}) to manage this laptop."
echo

# Check if already authorized
if grep -q "${KEY_NAME}" ~/.ssh/authorized_keys 2>/dev/null; then
    echo "✓ Control node key already authorized"
    exit 0
fi

# Ensure .ssh directory exists with correct permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Function to fetch and add key
add_control_node_key() {
    echo "Fetching SSH key from control node..."
    
    # Try to get the key from the control node
    if ssh verlyn13@${CONTROL_NODE} "cat ~/.ssh/${KEY_NAME}.pub" 2>/dev/null >> ~/.ssh/authorized_keys.tmp; then
        # Verify we got a valid key
        if grep -q "ssh-ed25519" ~/.ssh/authorized_keys.tmp; then
            cat ~/.ssh/authorized_keys.tmp >> ~/.ssh/authorized_keys
            rm ~/.ssh/authorized_keys.tmp
            chmod 600 ~/.ssh/authorized_keys
            echo "✓ Control node key successfully added"
            return 0
        else
            rm -f ~/.ssh/authorized_keys.tmp
            echo "✗ Invalid key format received"
            return 1
        fi
    else
        echo "✗ Could not fetch key from control node"
        return 1
    fi
}

# Alternative: Manual key addition
manual_key_addition() {
    echo
    echo "Manual key addition:"
    echo "1. SSH to control node: ssh verlyn13@${CONTROL_NODE}"
    echo "2. Get the key: cat ~/.ssh/${KEY_NAME}.pub"
    echo "3. Run this command locally:"
    echo "   echo 'PASTE_KEY_HERE' >> ~/.ssh/authorized_keys"
    echo
    echo "Or from the control node, run:"
    echo "   ssh-copy-id -i ~/.ssh/${KEY_NAME}.pub verlyn13@laptop.hq"
}

# Main execution
if ping -c 1 -W 2 ${CONTROL_IP} &>/dev/null; then
    if add_control_node_key; then
        echo
        echo "Success! The control node can now manage this laptop via Ansible."
        echo
        echo "Test with: ssh -i ~/.ssh/${KEY_NAME} verlyn13@laptop.hq (from control node)"
    else
        manual_key_addition
    fi
else
    echo "✗ Control node not reachable at ${CONTROL_IP}"
    echo
    echo "Please ensure:"
    echo "1. Tailscale is connected: tailscale status"
    echo "2. Control node is online: tailscale ping ${CONTROL_NODE}"
    echo
    manual_key_addition
fi