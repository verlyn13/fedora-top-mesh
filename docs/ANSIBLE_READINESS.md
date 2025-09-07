# Ansible Readiness for Fedora Laptop

## Phase 2 Configuration Management

This document describes the laptop's readiness and role in the Phase 2 Ansible implementation.

## Current Status

✅ **Ready for Ansible Management**

- **Mesh Connectivity**: Connected via Tailscale (100.84.2.8)
- **SSH Access**: Available to control node via mesh network
- **Inventory Entry**: Listed as `laptop.hq` in mesh-infra inventory
- **Python**: Available for Ansible modules
- **User**: `verlyn13` with sudo access

## Architecture Position

```
┌──────────────────────────────────────────────┐
│         Hetzner (Control Node)               │
│         100.84.151.58                        │
│         - Runs Ansible                       │
│         - Manages all nodes                  │
└──────────────┬───────────────────────────────┘
               │ Manages via SSH
               │
        ┌──────┴──────┐
        │  Tailscale  │
        │    Mesh     │
        └──────┬──────┘
               │
    ┌──────────┴──────────┐
    │   Fedora Laptop     │
    │   (Managed Node)    │
    │   100.84.2.8        │
    │   laptop.hq         │
    └─────────────────────┘
```

## Laptop as Managed Node

### What This Means

- **Receives Configuration**: Ansible pushes configuration from Hetzner
- **No Ansible Installation Required**: Only needs Python (already present)
- **SSH Key Authentication**: Control node uses SSH keys for access
- **Automatic Updates**: Configuration applied when online

### Expected Configurations

Based on Phase 2 planning, this laptop will receive:

1. **Common Role**
   - Baseline packages (tmux, htop, ripgrep, fzf, neovim)
   - Shell configurations
   - System utilities

2. **Security Role**
   - SSH hardening
   - Firewall rules (via firewalld on Fedora)
   - Security policies

3. **Tailscale Role**
   - Ensure Tailscale service running
   - Maintain mesh connectivity
   - Route configurations

4. **Development Tools** (via install-tools playbook)
   - Language runtimes
   - Development utilities
   - IDE configurations

## SSH Key Management

### Current State
- User: `verlyn13`
- SSH service: Running and accessible via Tailscale

### Expected Control Node Key
The Hetzner control node will generate an Ansible SSH key:
```
~/.ssh/ansible_ed25519.pub
```

### Authorization Required
When Phase 2 begins, authorize the control node's key:
```bash
# The control node will push its key, or manually:
ssh-copy-id -i ~/.ssh/ansible_ed25519.pub verlyn13@laptop.hq
```

## Ansible Variables

From inventory, this laptop has:
```yaml
device_type: laptop
os: fedora
location: roaming
expected_uptime: 40
development_environment: true
gui_available: true
```

## Pre-flight Checklist

| Requirement | Status | Notes |
|------------|--------|-------|
| Tailscale Connected | ✅ | IP: 100.84.2.8 |
| SSH Accessible | ✅ | Via mesh network |
| Python Installed | ✅ | Python 3.x available |
| Sudo Access | ✅ | User: verlyn13 |
| Firewall | ✅ | firewalld active |
| SELinux | ✅ | Enforcing mode |

## Special Considerations

### Intermittent Connectivity
- **Expected Uptime**: 40% (laptop may be offline)
- **Ansible Behavior**: Control node will skip if offline
- **Catch-up**: Configurations applied when reconnected

### Roaming Nature
- Network conditions vary
- May be behind restrictive firewalls
- Tailscale handles NAT traversal

### Resource Constraints
- Battery-powered device
- May sleep/hibernate
- Local tasks take priority

## Integration with Control Node

### Playbook Targeting
The control node can target this laptop specifically:
```bash
# From Hetzner control node
ansible-playbook -l laptop.hq playbooks/site.yaml
```

### Group Membership
Part of `workstations` group, receives:
- Development environment configurations
- GUI-aware settings
- Workstation-specific tools

## Security Considerations

1. **No Password Auth**: SSH keys only
2. **Mesh-Only Access**: No public SSH exposure
3. **Principle of Least Privilege**: Ansible uses sudo only when needed
4. **Audit Trail**: All Ansible runs logged on control node

## Monitoring and Reporting

This laptop reports status via:
- `scripts/report-status.sh` - Local status generation
- Ansible facts gathering - When control node connects
- Tailscale status - Network layer visibility

## Next Steps

1. **Wait for Control Node Setup**
   - Hetzner runs `make ansible-setup`
   - Generates SSH keys

2. **Authorize Control Node**
   - Accept SSH key from control node
   - Verify connectivity

3. **Receive Initial Configuration**
   - Common role baseline
   - Security hardening
   - Development tools

4. **Ongoing Management**
   - Automatic updates when online
   - Configuration drift prevention
   - Consistent environment

## Troubleshooting

### If Ansible Can't Connect

1. Check Tailscale status:
   ```bash
   tailscale status
   tailscale ping hetzner-hq
   ```

2. Verify SSH:
   ```bash
   systemctl status sshd
   ss -tlnp | grep :22
   ```

3. Check firewall:
   ```bash
   sudo firewall-cmd --list-all
   ```

4. Test from laptop to control node:
   ```bash
   ssh verlyn13@hetzner-hq
   ```

## Phase 2 Benefits for Laptop

- **Consistent Environment**: Same tools across all nodes
- **Automatic Maintenance**: Updates and patches managed centrally
- **Security Hardening**: Best practices applied automatically
- **Development Tools**: Standardized toolchain
- **Configuration Backup**: Settings stored in Git

---

*This laptop is ready for Phase 2 Ansible management. No local action required until the control node initiates contact.*