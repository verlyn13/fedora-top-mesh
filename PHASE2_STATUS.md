# Phase 2: Ansible Configuration Management

## Laptop Role and Readiness

This document describes the Fedora laptop's participation in Phase 2 of the mesh infrastructure deployment.

## Current Phase Status

### Phase 1: Network Foundation ✅ (66% Complete)
- ✅ Hetzner hub deployed (100.84.151.58)
- ✅ Fedora laptop connected (100.84.2.8)
- ⏳ WSL2 pending

### Phase 2: Configuration Management 🚧 (Ready)
- ✅ Ansible structure prepared in mesh-infra
- ✅ Control node designated (Hetzner)
- ✅ This laptop ready as managed node
- ⏳ Awaiting control node setup

## This Laptop's Role

### As a Managed Node

**Not a Control Node**: This laptop does NOT run Ansible. Instead:
- Receives configuration from Hetzner control node
- Executes Ansible modules via SSH
- Reports facts back to control node
- Maintains desired state as defined in mesh-infra

### Inventory Identity

```yaml
laptop.hq:
  ansible_host: 100.84.2.8
  device_type: laptop
  os: fedora
  location: roaming
  expected_uptime: 40
  groups:
    - workstations
    - all
```

## Readiness Checklist

| Component | Status | Details |
|-----------|--------|---------|
| **Network** | ✅ | Connected via Tailscale |
| **SSH** | ✅ | Accessible at laptop.hq |
| **Python** | ✅ | Required for Ansible modules |
| **Sudo** | ✅ | User verlyn13 has access |
| **Firewall** | ✅ | firewalld active |
| **SELinux** | ✅ | Enforcing mode |
| **Control Key** | ⏳ | Awaiting ansible_ed25519.pub |

## Expected Configurations

### From Common Role
- tmux, htop, ripgrep, fzf, neovim
- Shell configurations
- System utilities

### From Security Role
- SSH hardening
- Firewall rules (Fedora-specific)
- Security policies

### From Tailscale Role
- Service management
- Route configurations
- Mesh maintenance

### From Development Tools
- Language runtimes
- IDE configurations
- Build tools

## Integration Scripts

This repository provides scripts for Ansible integration:

1. **ansible-readiness-check.sh** - Verify readiness for management
2. **accept-control-node-key.sh** - Authorize control node SSH key
3. **ansible-facts.sh** - Generate Ansible-compatible facts

## Operational Considerations

### Intermittent Connectivity
- Laptop may be offline (40% expected uptime)
- Ansible will skip if unreachable
- Configurations applied when reconnected

### Resource Management
- Battery-powered device
- Local tasks have priority
- Ansible runs are non-disruptive

### Security
- SSH key authentication only
- Mesh-only access (no public SSH)
- All changes audited on control node

## Next Steps

### 1. Control Node Setup (on Hetzner)
```bash
cd /opt/mesh-infra
make ansible-setup
```

### 2. Key Authorization (on this laptop)
```bash
./scripts/accept-control-node-key.sh
# Or manually from control node:
ssh-copy-id -i ~/.ssh/ansible_ed25519.pub verlyn13@laptop.hq
```

### 3. First Ansible Run (from control node)
```bash
# Test connectivity
ansible laptop.hq -m ping

# Apply configuration
ansible-playbook -l laptop.hq playbooks/site.yaml
```

## Monitoring

Track Ansible management via:
- Control node logs at Hetzner
- Local script: `./scripts/ansible-readiness-check.sh`
- Status reports: `./scripts/report-status.sh`

## Benefits

✅ **Consistent Environment**: Same tools across all nodes  
✅ **Automatic Updates**: Centrally managed patches  
✅ **Security Hardening**: Best practices enforced  
✅ **Configuration Backup**: All settings in Git  
✅ **Drift Prevention**: Desired state maintained  

## Repository Updates

This fedora-top-mesh repository has been updated with:
- Ansible readiness documentation
- Integration configuration files
- Helper scripts for management
- Phase 2 status tracking

---

**Status**: Ready for Ansible management  
**Waiting For**: Control node setup on Hetzner  
**Last Updated**: 2025-09-07