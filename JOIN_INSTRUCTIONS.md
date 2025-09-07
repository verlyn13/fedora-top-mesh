# Joining the Mesh Network - Fedora Laptop

## Prerequisites
- Sudo access on this laptop
- GitHub account: jeffreyverlynjohnson@gmail.com (for Tailscale auth)

## Step-by-Step Instructions

### 1. Install Tailscale

Run this command and enter your sudo password when prompted:

```bash
make install
```

Or manually:
```bash
./scripts/install-tailscale.sh
```

### 2. Join the Mesh Network

After Tailscale is installed, join the mesh:

```bash
make join
```

This will:
- Start the Tailscale daemon
- Configure this laptop as "laptop-hq"
- Set it to accept routes from the hub
- Open a browser for authentication

### 3. Authenticate

When the browser opens:
1. Sign in with: jeffreyverlynjohnson@gmail.com
2. Authorize the device
3. The device name should show as "laptop-hq"

### 4. Verify Connection

Check that you're connected:

```bash
make status
```

Test connectivity to the hub:

```bash
make test
```

Or manually:
```bash
sudo tailscale ping hetzner-hq
```

## Expected Results

After successful joining:
- **Tailscale IP**: Should be assigned (likely 100.x.x.x)
- **Hostname**: laptop-hq
- **Hub Connectivity**: Should ping hetzner-hq (100.84.151.58)

## Quick Commands

```bash
# Check status
sudo tailscale status

# Get your IP
sudo tailscale ip -4

# Test hub
sudo tailscale ping hetzner-hq

# SSH to hub via mesh
ssh verlyn13@hetzner-hq -p 2222
# or
ssh verlyn13@100.84.151.58 -p 2222
```

## Troubleshooting

If connection fails:
1. Check daemon: `sudo systemctl status tailscaled`
2. Restart: `sudo systemctl restart tailscaled`
3. Re-authenticate: `sudo tailscale up --force-reauth`
4. Check logs: `sudo journalctl -u tailscaled -f`

## Next Steps

Once connected:
1. Update mesh-infra HQ: `make update-hq`
2. Test services access
3. Configure any laptop-specific services

## Repository Links
- **This Device**: https://github.com/verlyn13/fedora-top-mesh
- **Mesh HQ**: https://github.com/verlyn13/mesh-infra
- **Hub Node**: 100.84.151.58 (hetzner-hq)