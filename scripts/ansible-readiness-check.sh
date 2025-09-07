#!/bin/bash
# Ansible Readiness Check for Fedora Laptop
# Verifies this node is ready for Ansible management

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Ansible Readiness Check for laptop.hq ==="
echo

READY=true

# Check Tailscale connectivity
echo -n "Checking Tailscale connectivity... "
if tailscale status &>/dev/null; then
    TS_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓${NC} Connected (IP: $TS_IP)"
else
    echo -e "${RED}✗${NC} Not connected"
    READY=false
fi

# Check SSH service
echo -n "Checking SSH service... "
if systemctl is-active sshd &>/dev/null || systemctl is-active ssh &>/dev/null; then
    echo -e "${GREEN}✓${NC} Running"
else
    echo -e "${RED}✗${NC} Not running"
    READY=false
fi

# Check Python availability
echo -n "Checking Python... "
if command -v python3 &>/dev/null; then
    PY_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Available (v$PY_VERSION)"
else
    echo -e "${RED}✗${NC} Not found"
    READY=false
fi

# Check sudo access
echo -n "Checking sudo access... "
if sudo -n true 2>/dev/null || sudo -l &>/dev/null; then
    echo -e "${GREEN}✓${NC} Available"
else
    echo -e "${YELLOW}⚠${NC} May require password"
fi

# Check connectivity to control node
echo -n "Checking control node connectivity... "
if ping -c 1 -W 2 100.84.151.58 &>/dev/null; then
    echo -e "${GREEN}✓${NC} Reachable (hetzner-hq)"
else
    echo -e "${RED}✗${NC} Cannot reach control node"
    READY=false
fi

# Check firewall status
echo -n "Checking firewall... "
if systemctl is-active firewalld &>/dev/null; then
    echo -e "${GREEN}✓${NC} Active (firewalld)"
elif systemctl is-active ufw &>/dev/null; then
    echo -e "${GREEN}✓${NC} Active (ufw)"
else
    echo -e "${YELLOW}⚠${NC} No firewall detected"
fi

# Check SELinux status
echo -n "Checking SELinux... "
if command -v getenforce &>/dev/null; then
    SELINUX_STATUS=$(getenforce)
    if [[ "$SELINUX_STATUS" == "Enforcing" ]]; then
        echo -e "${GREEN}✓${NC} Enforcing"
    else
        echo -e "${YELLOW}⚠${NC} $SELINUX_STATUS"
    fi
else
    echo -e "${YELLOW}⚠${NC} Not installed"
fi

# Check for control node SSH key
echo -n "Checking for control node SSH key... "
if grep -q "ansible_ed25519" ~/.ssh/authorized_keys 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Authorized"
else
    echo -e "${YELLOW}⚠${NC} Not yet authorized"
    echo "  → Control node will need to run: ssh-copy-id verlyn13@laptop.hq"
fi

# Check system resources
echo -n "Checking system resources... "
MEM_AVAILABLE=$(free -g | awk '/^Mem:/{print $7}')
LOAD=$(uptime | awk -F'load average:' '{print $2}')
echo -e "${GREEN}✓${NC} ${MEM_AVAILABLE}GB free, load:${LOAD}"

# Summary
echo
echo "=== Readiness Summary ==="
if [ "$READY" = true ]; then
    echo -e "${GREEN}✅ This node is ready for Ansible management${NC}"
    echo
    echo "Next steps:"
    echo "1. Control node runs: make ansible-setup (on hetzner-hq)"
    echo "2. Control node runs: ssh-copy-id -i ~/.ssh/ansible_ed25519.pub verlyn13@laptop.hq"
    echo "3. Control node runs: ansible-playbook -l laptop.hq playbooks/site.yaml"
else
    echo -e "${RED}❌ This node is not ready for Ansible management${NC}"
    echo
    echo "Please fix the issues above and run this check again."
fi

# Export status for other scripts
exit $([ "$READY" = true ] && echo 0 || echo 1)