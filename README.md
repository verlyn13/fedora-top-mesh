# Fedora-Top Mesh Configuration

Device-specific configuration for `fedora-top` laptop in the mesh infrastructure.

## Node Details

- **Hostname**: fedora-top
- **Tailscale Name**: laptop-hq
- **Role**: Workstation, Roaming Device, Ansible Managed Node
- **Mesh IP**: 100.84.2.8 (active)
- **Status**: Phase 1 & 2 Complete - Fully Operational

## Purpose

This repository contains the specific configuration for the Fedora laptop (ThinkPad) as part of the three-node mesh infrastructure. It complements the central `mesh-infra` repository by maintaining device-specific settings, credentials, and customizations.

## Relationship to mesh-infra

- **mesh-infra**: Central infrastructure definitions, policies, and shared configurations
- **fedora-top-mesh**: This laptop's specific implementation and state
- **fedora-wsl-mesh**: WSL node (wsl-fedora-kbc) at University of Alaska

## Configuration Structure

```
fedora-top-mesh/
├── config/
│   ├── mesh-integration.yml    # Integration with mesh-infra
│   └── ansible-integration.yml # Ansible management config
├── scripts/
│   ├── join-mesh.sh                   # Join mesh network
│   ├── report-status.sh              # Generate status reports
│   ├── ansible-readiness-check.sh    # Verify Ansible readiness
│   ├── configure-ansible-sudo.sh     # Setup passwordless sudo
│   ├── test-ansible-connectivity.sh  # Test management connectivity
│   └── ansible-facts.sh              # Generate Ansible facts
├── state/
│   └── current.json                  # Current device state
├── docs/
│   ├── ANSIBLE_READINESS.md         # Ansible setup documentation
│   └── INTEGRATION.md               # Integration patterns
└── DEPLOYMENT_STATUS.md             # Current deployment status
```

## Current Capabilities

### Phase 1: Network Foundation ✅
- Connected to Tailscale mesh at 100.84.2.8
- Hub connectivity verified (hetzner-hq)
- Service discovery operational

### Phase 2: Configuration Management ✅
- Ansible managed node ready
- SSH key authorized for control node
- Passwordless sudo configured
- Full automation enabled

### Services Provided
- Development Environment (16 cores, 15GB RAM)
- AI Agent Host (Claude Code, Codex, Gemini)
- Build Runner (Node.js, Python, Go, Rust)
- Ansible Managed Node

## Management

### From Control Node (hetzner-hq)
```bash
# Basic connectivity
ansible laptop.hq -m ping

# Apply configuration
ansible-playbook -l laptop.hq playbooks/site.yaml

# Install development tools
ansible-playbook -l laptop.hq playbooks/install-tools.yaml
```

### Local Operations
```bash
# Check readiness
./scripts/ansible-readiness-check.sh

# Generate status report
./scripts/report-status.sh

# Test connectivity
./scripts/test-ansible-connectivity.sh
```

## Security Notes

- Never commit actual credentials to this repository
- Use `.env` files (gitignored) for sensitive configuration
- Sync secrets via gopass as defined in mesh-infra policies

## Maintenance

This repository should be kept in sync with mesh-infra policies while maintaining device-specific state and configuration.

## Links

- [Main Infrastructure Repository](https://github.com/verlyn13/mesh-infra)
- [Network Architecture](https://github.com/verlyn13/mesh-infra/blob/main/docs/_grounding/facts.yml)

## Status

✅ **Operational**: Fully integrated mesh node with Ansible management ready

---

Last Updated: 2025-09-07