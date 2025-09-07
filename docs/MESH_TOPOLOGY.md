# Mesh Network Topology

## Three-Node Mesh Network

### Current Active Nodes

| Node Name | Tailscale IP | Role | Status | Location | Phase |
|-----------|--------------|------|--------|----------|-------|
| **hetzner-hq** | 100.84.151.58 | Primary Server / Ansible Control | 🟢 Active | Hetzner Cloud | Phase 2 ✅ |
| **laptop-hq** | 100.84.2.8 | Development Laptop / Managed Node | 🟢 Active | Roaming (This Node) | Phase 2 ✅ |
| **wsl-fedora-kbc** | 100.88.131.44 | WSL Bridge Node | 🟢 Active | University of Alaska | Phase 1 ✅ |

## Network Diagram

```
                ┌─────────────────────┐
                │     mesh-infra      │
                │   (Headquarters)     │
                └──────────┬──────────┘
                           │
    ┌──────────────────────┼──────────────────────┐
    │                      │                      │
┌────▼──────────┐    ┌─────▼──────┐    ┌─────────▼────────┐
│  hetzner-hq   │◄───┤ laptop-hq  │───►│ wsl-fedora-kbc   │
│ 100.84.151.58 │    │ 100.84.2.8 │    │  100.88.131.44   │
│ (Primary/Hub) │    │ (This Node)│    │   (WSL Bridge)   │
│    Phase 2    │    │   Phase 2  │    │     Phase 1      │
└───────────────┘    └────────────┘    └──────────────────┘
     Cloud                Mobile           University Network
                                            137.229.236.139
```

## Node Capabilities

### hetzner-hq (Primary Hub)
- **Type**: Cloud VPS
- **Role**: Exit node, persistent storage, Ansible control node
- **Services**: 
  - Always-on services
  - Central monitoring
  - Configuration management (Ansible)
  - Persistent storage
- **Availability**: 24/7
- **Management**: Self-managed

### laptop-hq (This Node - fedora-top)
- **Type**: ThinkPad Laptop
- **Role**: Development workstation, Ansible managed node
- **Services**:
  - Development environment (16 cores, 15GB RAM)
  - AI Agent Host (Claude Code, Codex, Gemini)
  - Build Runner (Node.js, Python, Go, Rust)
- **Availability**: ~40% (intermittent, roaming)
- **Management**: Ansible-managed from hetzner-hq

### wsl-fedora-kbc (WSL Bridge)
- **Type**: WSL2 on Windows 11
- **Role**: Bridge between Windows and Linux mesh
- **Services**:
  - Cross-platform integration
  - University network resources access
  - Windows filesystem access
  - WSL development environment
- **Availability**: Business hours (Alaska Time)
- **Management**: In progress (Phase 1 complete)

## Connectivity Matrix

| From ↓ / To → | hetzner-hq | laptop-hq | wsl-fedora-kbc |
|---------------|------------|-----------|----------------|
| **hetzner-hq** | - | ✅ Direct | ✅ Direct |
| **laptop-hq** | ✅ Direct | - | ✅ Via Tailscale |
| **wsl-fedora-kbc** | ✅ ~460ms | ✅ ~217ms | - |

## Phase Completion Status

### Phase 1: Network Foundation
- ✅ hetzner-hq: Complete
- ✅ laptop-hq: Complete  
- ✅ wsl-fedora-kbc: Complete

### Phase 2: Configuration Management
- ✅ hetzner-hq: Ansible control node configured
- ✅ laptop-hq: Ansible managed node ready
- 🔄 wsl-fedora-kbc: Pending (next target)

## Management Hierarchy

```
hetzner-hq (Control Node)
    │
    ├── Manages: laptop-hq
    │   - SSH key authorized
    │   - Passwordless sudo configured
    │   - Full automation enabled
    │
    └── Will Manage: wsl-fedora-kbc
        - Phase 2 pending
        - SSH access available
        - Ansible setup required
```

## Network Services

### Provided by hetzner-hq
- Exit node for consistent IP
- Persistent storage and backups
- Always-on services (databases, APIs)
- Ansible control and automation

### Provided by laptop-hq (This Node)
- Development and testing environment
- AI-assisted coding tools
- Local build execution
- Roaming connectivity

### Provided by wsl-fedora-kbc
- Windows/Linux bridge
- University network access
- Academic resources gateway
- Cross-platform testing

## Security Architecture

- **VPN**: All inter-node traffic via Tailscale
- **Authentication**: SSH keys only
- **Authorization**: Ansible via authorized keys
- **Encryption**: WireGuard protocol
- **Access Control**: MagicDNS and ACLs

## Operational Notes

### This Node (laptop-hq)
- Intermittent connectivity expected
- Ansible-managed from hetzner-hq
- Reports status every 5 minutes when online
- Syncs with mesh-infra policies

### Peer Nodes
- **hetzner-hq**: Always available, primary contact point
- **wsl-fedora-kbc**: Available during Alaska business hours

## Integration Points

All nodes integrate through:
1. Tailscale mesh network (100.x.x.x addresses)
2. Shared mesh-infra repository
3. Status reporting to hetzner-hq
4. Ansible management (Phase 2 nodes)

---

*Last Updated: 2025-09-07*
*Network Version: 1.0*
*Total Nodes: 3 (All Operational)*