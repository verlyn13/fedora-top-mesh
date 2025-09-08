# Laptop Deployment Guide - mesh-ops User

## Pre-Deployment Preparation

This guide walks through deploying the mesh-ops user on this Fedora laptop (fedora-top).

### Current Environment
- **Node**: laptop-hq (100.84.2.8)
- **OS**: Fedora Linux 42
- **User**: verlyn13 (current admin)
- **Status**: Ready for mesh-ops deployment

### Prerequisites Checklist

✅ **Verified Prerequisites**:
- Tailscale connected (100.84.2.8)
- SSH service running
- Sudo access available (verlyn13)
- Ansible managed by hetzner-hq
- 16 cores, 15GB RAM available

⚠️ **Pre-Deployment Checks**:
```bash
# Verify mesh connectivity
tailscale status | grep -E "(laptop-hq|hetzner-hq|wsl-fedora)"

# Confirm sudo works
sudo whoami  # Should return "root"

# Check current users
grep -E "^(verlyn13|mesh-ops):" /etc/passwd

# Verify mesh-infra repository
cd /home/verlyn13/Projects/verlyn13/mesh-infra && git status
```

## Deployment Process

### Step 1: Prepare mesh-infra Repository
```bash
# Navigate to mesh-infra
cd /home/verlyn13/Projects/verlyn13/mesh-infra

# Ensure latest updates
git pull origin main

# Review deployment script
cat scripts/deploy-laptop.sh
```

### Step 2: Execute Deployment

#### Option A: Automated Deployment (Recommended)
```bash
# Run the laptop-specific deployment script
./scripts/deploy-laptop.sh
```

#### Option B: Makefile Approach
```bash
# Use Makefile targets for step-by-step deployment
make mesh-user-create      # Create mesh-ops user
make mesh-user-validate    # Validate creation
make mesh-user-bootstrap   # Bootstrap environment
```

#### Option C: Manual Deployment
```bash
# Direct script execution with sudo
sudo scripts/create-mesh-ops-user.sh

# Then validate
scripts/validate-mesh-ops.sh
```

### Step 3: Monitor Deployment
The deployment script will:
1. Create mesh-ops user with UID 2000
2. Configure home directory at /home/mesh-ops
3. Set up SSH keys for mesh access
4. Configure sudoers for passwordless operations
5. Set fish as default shell (or bash if fish unavailable)
6. Initialize mesh environment

Expected output:
```
Creating mesh-ops user...
✓ User created with UID 2000
✓ Home directory configured
✓ SSH keys installed
✓ Sudo access configured
✓ Shell set to /usr/bin/fish
✓ Environment initialized
Deployment complete!
```

## Post-Deployment Validation

### Essential Checks
```bash
# 1. Verify user exists
id mesh-ops
# Expected: uid=2000(mesh-ops) gid=2000(mesh-ops) groups=2000(mesh-ops)

# 2. Check home directory
ls -ld /home/mesh-ops
# Expected: drwx------. mesh-ops mesh-ops /home/mesh-ops

# 3. Verify SSH setup
sudo ls -la /home/mesh-ops/.ssh/
# Expected: authorized_keys file present with correct permissions

# 4. Test sudo access
sudo -u mesh-ops sudo -n true && echo "✓ Sudo works"

# 5. Check shell
getent passwd mesh-ops | cut -d: -f7
# Expected: /usr/bin/fish or /bin/bash
```

### Mesh Connectivity Tests
```bash
# Test as mesh-ops user
sudo -u mesh-ops tailscale status

# Verify mesh access to other nodes
sudo -u mesh-ops tailscale ping hetzner-hq
sudo -u mesh-ops tailscale ping wsl-fedora-kbc

# Check SSH connectivity
sudo -u mesh-ops ssh -o ConnectTimeout=5 mesh-ops@hetzner-hq echo "Connected"
```

### Service Verification
```bash
# Check if mesh-ops can access required services
sudo -u mesh-ops systemctl status tailscaled
sudo -u mesh-ops journalctl -u tailscaled -n 10
```

## Troubleshooting

### Common Issues and Solutions

#### User Creation Fails
```bash
# Check if user already exists
getent passwd mesh-ops

# If exists, remove and retry
sudo userdel -r mesh-ops
sudo groupdel mesh-ops 2>/dev/null
```

#### SSH Key Issues
```bash
# Manually create SSH directory
sudo mkdir -p /home/mesh-ops/.ssh
sudo chmod 700 /home/mesh-ops/.ssh
sudo chown -R mesh-ops:mesh-ops /home/mesh-ops/.ssh
```

#### Sudo Not Working
```bash
# Check sudoers file
sudo cat /etc/sudoers.d/mesh-ops
# Should contain: mesh-ops ALL=(ALL) NOPASSWD:ALL

# If missing, create it
echo "mesh-ops ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/mesh-ops
sudo chmod 440 /etc/sudoers.d/mesh-ops
```

#### Shell Issues
```bash
# If fish not available, use bash
sudo chsh -s /bin/bash mesh-ops

# Verify shell change
getent passwd mesh-ops | cut -d: -f7
```

## Success Criteria

✅ **Deployment is successful when**:
1. mesh-ops user exists with UID 2000
2. Home directory properly configured
3. SSH keys installed and permissions correct
4. Passwordless sudo operational
5. Can connect to other mesh nodes
6. Shell environment functional

## Next Steps After Success

### Update Documentation
1. Mark laptop deployment complete in mesh-infra
2. Document any laptop-specific adjustments
3. Update this repository's status files

### Prepare for Hetzner Deployment
1. Review laptop deployment logs for insights
2. Note any adjustments needed for control node
3. Plan Hetzner deployment timing

### Verification Commands
```bash
# Generate deployment report
echo "=== Laptop Deployment Report ==="
echo "Date: $(date)"
echo "Node: laptop-hq (100.84.2.8)"
echo "User: $(id mesh-ops)"
echo "Shell: $(getent passwd mesh-ops | cut -d: -f7)"
echo "Sudo: $(sudo -u mesh-ops sudo -n true && echo 'Working' || echo 'Failed')"
echo "Mesh: $(sudo -u mesh-ops tailscale status | grep laptop-hq)"
```

---

**Ready to Deploy**: All prerequisites met  
**Risk Level**: Low (WSL already proved difficult scenarios)  
**Estimated Time**: 5-10 minutes  
**Rollback Plan**: User can be removed if issues occur  

Execute deployment when ready!