# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a device-specific mesh network configuration repository for a Fedora laptop (ThinkPad) that participates in a three-node Tailscale mesh infrastructure. It manages the laptop's integration with the central `mesh-infra` repository as an Ansible-managed node.

### Mesh Network Nodes
- **hetzner-hq** (100.84.151.58): Primary hub, Ansible control node, always-on services
- **laptop-hq** (100.84.2.8): This node, development workstation, Ansible managed 
- **wsl-fedora-kbc** (100.88.131.44): WSL bridge node at University of Alaska

## Key Commands

### Mesh Network Operations
```bash
make status        # Check current Tailscale mesh status and IP
make test          # Test connectivity to hub (hetzner-hq)
make join          # Join the mesh network (initial setup)
make sync-config   # Pull latest config from mesh-infra
make update-hq     # Report status to mesh-infra
```

### Ansible & Configuration Management
```bash
./scripts/ansible-readiness-check.sh      # Verify Ansible readiness
./scripts/test-ansible-connectivity.sh    # Test management connectivity
./scripts/report-status.sh                # Generate status report for hub
./scripts/ansible-facts.sh                # Generate Ansible facts
```

## Architecture & Structure

### Repository Relationship
- **This repo (fedora-top-mesh)**: Device-specific implementation, state tracking, and local configuration
- **Parent repo (mesh-infra)**: Central infrastructure policies, network topology, and coordination
- Located at: `../mesh-infra` (expected sibling directory)

### Network Identity
- **Hostname**: fedora-top
- **Tailscale Name**: laptop-hq  
- **Mesh IP**: 100.84.2.8
- **Hub**: hetzner-hq (control node)

### Core Configuration Files
- `device-profile.yml`: Comprehensive device capabilities and specifications
- `config/mesh-integration.yml`: Integration settings, API endpoints, and sync configuration
- `config/ansible-integration.yml`: Ansible management configuration
- `state/current.json`: Current device state cache

### Script Architecture
All scripts in `scripts/` are bash scripts that:
- Handle mesh network operations (join, status reporting)
- Manage Ansible integration (SSH keys, sudo configuration)
- Report to and sync with the central hub (hetzner-hq)

### Service Integration
This node:
- **Provides**: Development environment, AI agent hosting, build runner, Ansible managed node
- **Consumes**: Exit node, persistent storage, always-on services from hetzner-hq
- **Reports**: Status, connectivity, resources, and health to hub every 5 minutes

### Operational Characteristics
- **Availability**: Intermittent (laptop, not always online)
- **Management**: Ansible-managed from hetzner-hq control node
- **SSH**: Passwordless sudo configured for ansible user
- **Connectivity**: Primary via Tailscale mesh, fallback to direct SSH on trusted networks