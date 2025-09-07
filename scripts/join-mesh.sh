#!/bin/bash
# Join this laptop to the mesh network via Tailscale
set -euo pipefail

echo "=== Joining Fedora Laptop to Mesh Network ==="
echo
echo "Device: fedora-top"
echo "Mesh Name: laptop-hq"
echo "Repository: fedora-top-mesh"
echo

# Check hostname
HOSTNAME=$(hostname)
if [ "$HOSTNAME" != "fedora-top" ]; then
    echo "⚠ Warning: Expected hostname 'fedora-top', got '$HOSTNAME'"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install Tailscale if not present
if ! command -v tailscale &> /dev/null; then
    echo "Tailscale not found. Please install it first:"
    echo
    echo "Option 1: Run the official installer (requires sudo):"
    echo "  curl -fsSL https://tailscale.com/install.sh | sh"
    echo
    echo "Option 2: Install via dnf (Fedora):"
    echo "  sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
    echo "  sudo dnf install tailscale"
    echo
    echo "After installation, run this script again."
    exit 1
else
    echo "✓ Tailscale already installed"
fi

# Start Tailscale daemon if not running
if ! pgrep tailscaled > /dev/null; then
    echo "Starting Tailscale daemon..."
    sudo systemctl start tailscaled
    sudo systemctl enable tailscaled
    sleep 2
fi

echo
echo "Configuring Tailscale for laptop node..."
echo "- Hostname: laptop-hq"
echo "- Role: Roaming workstation"
echo "- Accept routes from hub"
echo

# Configure Tailscale
sudo tailscale up \
    --accept-routes \
    --hostname=laptop-hq \
    --accept-dns=true \
    --operator=$USER

echo
echo "✓ Tailscale configuration initiated"
echo
echo "Next steps:"
echo "1. Authenticate in browser if prompted"
echo "2. Verify connection: tailscale status"
echo "3. Test hub connectivity: tailscale ping hetzner-hq"
echo "4. Update status: ./scripts/report-status.sh"