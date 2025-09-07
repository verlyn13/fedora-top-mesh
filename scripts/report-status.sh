#!/bin/bash
# Report device status to mesh-infra
# This script generates a status report that mesh-infra can consume

set -euo pipefail

# Configuration
DEVICE_ID="fedora-top"
MESH_NAME="laptop-hq"
STATE_FILE="../state/current.json"
PROFILE_FILE="../device-profile.yml"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo -e "${GREEN}Generating status report for ${DEVICE_ID}...${NC}"

# Gather system information
get_system_info() {
    cat <<EOF
{
  "hostname": "$(hostname)",
  "kernel": "$(uname -r)",
  "uptime_seconds": $(awk '{print int($1)}' /proc/uptime),
  "load_average": [$(cat /proc/loadavg | awk '{print $1","$2","$3}')],
  "cpu_count": $(nproc),
  "memory_total_gb": $(free -g | awk '/^Mem:/{print $2}'),
  "memory_available_gb": $(free -g | awk '/^Mem:/{print $7}'),
  "disk_usage_percent": $(df -h / | awk 'NR==2 {print substr($5, 1, length($5)-1)}')
}
EOF
}

# Check network connectivity
get_network_status() {
    local tailscale_status="disconnected"
    local mesh_connectivity="false"
    
    # Check if Tailscale is running
    if command -v tailscale &> /dev/null; then
        if tailscale status &> /dev/null; then
            tailscale_status="connected"
            # Check connectivity to hub
            if ping -c 1 -W 2 100.84.151.58 &> /dev/null; then
                mesh_connectivity="true"
            fi
        fi
    fi
    
    # Get current network interfaces
    local interfaces=$(ip -j link show | jq -r '.[] | select(.operstate=="UP") | .ifname' | paste -sd "," -)
    
    cat <<EOF
{
  "tailscale_status": "${tailscale_status}",
  "mesh_connectivity": ${mesh_connectivity},
  "active_interfaces": "${interfaces}",
  "public_ip": "$(curl -s -m 2 ifconfig.me || echo "unknown")"
}
EOF
}

# Check service status
get_service_status() {
    local services=()
    
    # Check common development services
    if command -v docker &> /dev/null && systemctl is-active docker &> /dev/null; then
        services+=("docker")
    fi
    
    if command -v node &> /dev/null; then
        services+=("nodejs")
    fi
    
    if command -v python3 &> /dev/null; then
        services+=("python")
    fi
    
    if command -v go &> /dev/null; then
        services+=("golang")
    fi
    
    # Convert to JSON array
    local json_services=$(printf '"%s",' "${services[@]}" | sed 's/,$//')
    echo "{\"available_services\": [${json_services}]}"
}

# Generate complete status report
generate_report() {
    cat <<EOF
{
  "device_id": "${DEVICE_ID}",
  "mesh_name": "${MESH_NAME}",
  "timestamp": "${TIMESTAMP}",
  "status": "online",
  "system": $(get_system_info),
  "network": $(get_network_status),
  "services": $(get_service_status),
  "role": {
    "type": "workstation",
    "capabilities": ["development", "ai_assisted", "roaming"],
    "priority": "secondary"
  }
}
EOF
}

# Main execution
main() {
    # Ensure state directory exists
    mkdir -p "$(dirname "${STATE_FILE}")"
    
    # Generate report
    REPORT=$(generate_report)
    
    # Save to state file
    echo "${REPORT}" | jq '.' > "${STATE_FILE}"
    
    echo -e "${GREEN}Status report saved to ${STATE_FILE}${NC}"
    
    # If connected to mesh, attempt to sync with hub
    if [[ $(echo "${REPORT}" | jq -r '.network.mesh_connectivity') == "true" ]]; then
        echo -e "${YELLOW}Mesh connectivity detected. Ready to sync with hub.${NC}"
        # Future: implement actual sync mechanism
    else
        echo -e "${YELLOW}No mesh connectivity. Report saved locally.${NC}"
    fi
    
    # Output report (can be piped to other commands)
    echo "${REPORT}" | jq '.'
}

# Run main function
main "$@"