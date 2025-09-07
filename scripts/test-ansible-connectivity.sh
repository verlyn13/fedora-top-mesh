#!/bin/bash
# Test Ansible connectivity from laptop perspective
# Verifies all requirements for Ansible management

set -euo pipefail

echo "=== Testing Ansible Connectivity for laptop.hq ==="
echo

# Test SSH key authorization
echo -n "Testing SSH key authorization... "
if grep -q "ansible@hetzner.hq" ~/.ssh/authorized_keys; then
    echo "✅ Control node key found in authorized_keys"
else
    echo "❌ Control node key not found"
    echo "Run: echo 'ssh-ed25519 AAAAC3Nza...' >> ~/.ssh/authorized_keys"
    exit 1
fi

# Test passwordless sudo
echo -n "Testing passwordless sudo... "
if sudo -n true 2>/dev/null; then
    echo "✅ Passwordless sudo working"
else
    echo "❌ Passwordless sudo not configured"
    echo "Run: sudo ./scripts/configure-ansible-sudo.sh"
    exit 1
fi

# Test Tailscale connectivity to control node
echo -n "Testing Tailscale connectivity to control node... "
if tailscale ping -c 1 hetzner-hq >/dev/null 2>&1; then
    echo "✅ Can reach hetzner-hq via Tailscale"
else
    echo "❌ Cannot reach control node"
    echo "Check: tailscale status"
    exit 1
fi

# Test SSH service
echo -n "Testing SSH service... "
if systemctl is-active sshd >/dev/null 2>&1; then
    echo "✅ SSH service running"
else
    echo "❌ SSH service not running"
    echo "Run: sudo systemctl start sshd"
    exit 1
fi

# Test Python for Ansible
echo -n "Testing Python availability... "
if command -v python3 >/dev/null 2>&1; then
    PY_VERSION=$(python3 --version | cut -d' ' -f2)
    echo "✅ Python $PY_VERSION available"
else
    echo "❌ Python not found"
    exit 1
fi

# Generate system facts for verification
echo
echo "=== System Facts for Ansible ==="
echo "Hostname: $(hostname)"
echo "OS: $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "CPU Cores: $(nproc)"
echo "Memory: $(free -h | awk '/^Mem:/{print $2}')"
echo "Tailscale IP: $(tailscale ip -4 2>/dev/null || echo 'Not available')"

echo
echo "=== Connectivity Test Summary ==="
echo "✅ This laptop is ready for Ansible management!"
echo
echo "From the control node (hetzner-hq), you can now run:"
echo "  ansible laptop.hq -m ping"
echo "  ansible laptop.hq -m setup"
echo "  ansible-playbook -l laptop.hq playbooks/site.yaml"
echo "  ansible-playbook -l laptop.hq playbooks/install-tools.yaml"