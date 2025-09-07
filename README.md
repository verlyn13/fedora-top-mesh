# Fedora-Top Mesh Configuration

Device-specific configuration for `fedora-top` laptop in the mesh infrastructure.

## Node Details

- **Hostname**: fedora-top
- **Tailscale Name**: laptop-hq
- **Role**: Workstation, Roaming Device
- **Mesh IP**: 10.0.0.2/24 (planned)
- **Status**: Pending Deployment

## Purpose

This repository contains the specific configuration for the Fedora laptop (ThinkPad) as part of the three-node mesh infrastructure. It complements the central `mesh-infra` repository by maintaining device-specific settings, credentials, and customizations.

## Relationship to mesh-infra

- **mesh-infra**: Central infrastructure definitions, policies, and shared configurations
- **fedora-top-mesh**: This laptop's specific implementation and state

## Configuration Structure

```
fedora-top-mesh/
├── config/
│   ├── tailscale/      # Tailscale-specific settings
│   ├── wireguard/      # WireGuard fallback configs
│   └── services/       # Local service configurations
├── scripts/
│   ├── join-mesh.sh    # Script to join the mesh network
│   ├── health-check.sh # Connectivity verification
│   └── sync-state.sh   # Sync with mesh-infra
├── state/
│   └── current.json    # Current device state
└── .env.example        # Environment variables template
```

## Getting Started

1. **Prerequisites**
   - Tailscale installed
   - SSH keys configured
   - Access to mesh-infra repository

2. **Join the Mesh**
   ```bash
   ./scripts/join-mesh.sh
   ```

3. **Verify Connectivity**
   ```bash
   ./scripts/health-check.sh
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

⏳ **Pending**: Awaiting mesh network join procedure

---

Last Updated: 2025-09-07