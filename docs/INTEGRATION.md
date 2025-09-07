# Integration with mesh-infra

This document describes how `fedora-top-mesh` integrates with the main `mesh-infra` repository.

## Repository Relationship

```
mesh-infra/                 # Central infrastructure definition
    ├── defines policies
    ├── manages network topology  
    └── coordinates all nodes

fedora-top-mesh/           # This device's implementation
    ├── implements policies
    ├── reports device state
    └── provides local services
```

## Communication Flow

### 1. Device → Hub Reporting
The laptop reports its status to the mesh hub (hetzner-hq):

```yaml
Reports:
  - Current status (online/offline/degraded)
  - Available services
  - Resource utilization
  - Network connectivity
  - Service health
```

### 2. Hub → Device Configuration
The hub pushes configuration to this device:

```yaml
Receives:
  - Network policies
  - Routing tables
  - Security updates
  - Service discovery information
```

## Key Files for Integration

### In This Repository (fedora-top-mesh)

1. **device-profile.yml** - Comprehensive device capabilities and specifications
2. **config/role-definition.yml** - Defines this device's role in the mesh
3. **config/mesh-integration.yml** - Integration settings and endpoints
4. **scripts/report-status.sh** - Generates status reports for mesh-infra

### In mesh-infra Repository

The mesh-infra repository should reference this device in:

1. **docs/_grounding/facts.yml** - Network facts including this device
2. **docs/_grounding/network-reference.yaml** - Network topology
3. **infra/inventory/hosts** - Ansible inventory (future)

## Status Reporting

This device reports status in JSON format:

```json
{
  "device_id": "fedora-top",
  "mesh_name": "laptop-hq",
  "timestamp": "2025-09-07T12:00:00Z",
  "status": "online",
  "system": {
    "hostname": "fedora-top",
    "uptime_seconds": 3600,
    "load_average": [0.5, 0.3, 0.2]
  },
  "network": {
    "tailscale_status": "connected",
    "mesh_connectivity": true
  },
  "services": {
    "available_services": ["docker", "nodejs", "python"]
  }
}
```

## Service Discovery

This device advertises the following services to the mesh:

- **development_environment** - Full dev stack
- **ai_agent_host** - AI coding assistants
- **build_runner** - Local build execution

## Synchronization Strategy

1. **Online Mode**: Real-time sync with mesh-infra
2. **Offline Mode**: Queue changes locally, sync when reconnected
3. **Degraded Mode**: Best-effort sync with retries

## API Endpoints (When Online)

- `http://laptop-hq.hq:9090/status` - Current device status
- `http://laptop-hq.hq:9090/metrics` - Prometheus metrics
- `http://laptop-hq.hq:9090/config` - Current configuration

## Using This Integration

### For mesh-infra

When mesh-infra needs information about this laptop:

1. Check `device-profile.yml` for capabilities
2. Query status endpoint for current state
3. Reference `role-definition.yml` for expected behavior

### For This Device

To participate in the mesh:

1. Run `scripts/report-status.sh` to generate status
2. Sync with mesh-infra policies
3. Implement role as defined in `config/role-definition.yml`

## Future Enhancements

- [ ] Automated status reporting via systemd timer
- [ ] GraphQL API for richer queries
- [ ] Event-driven updates via webhooks
- [ ] Metrics collection with Prometheus
- [ ] Log aggregation to central hub