#!/bin/bash
# Install Tailscale on Fedora
set -euo pipefail

echo "=== Tailscale Installation for Fedora ==="
echo
echo "This script will install Tailscale from the official repository."
echo "You will need to enter your sudo password."
echo

# Check if already installed
if command -v tailscale &> /dev/null; then
    echo "✓ Tailscale is already installed"
    tailscale version
    exit 0
fi

echo "Installing Tailscale..."
echo

# Add Tailscale repository
echo "Step 1: Adding Tailscale repository..."
# Download repo file directly
sudo curl -fsSL https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

echo
echo "Step 2: Installing Tailscale package..."
sudo dnf install -y tailscale

echo
echo "Step 3: Enabling Tailscale service..."
sudo systemctl enable --now tailscaled

echo
echo "✓ Tailscale installation complete!"
echo
echo "Version installed:"
tailscale version

echo
echo "Next step: Run ./scripts/join-mesh.sh to join the mesh network"