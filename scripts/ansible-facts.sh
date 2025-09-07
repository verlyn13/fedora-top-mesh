#!/bin/bash
# Generate Ansible-compatible facts about this laptop
# Can be used by control node for inventory validation

set -euo pipefail

# Generate facts in JSON format
generate_facts() {
    cat <<EOF
{
  "ansible_hostname": "$(hostname)",
  "ansible_fqdn": "$(hostname -f 2>/dev/null || hostname)",
  "ansible_distribution": "$(grep '^NAME=' /etc/os-release | cut -d'"' -f2)",
  "ansible_distribution_version": "$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2)",
  "ansible_kernel": "$(uname -r)",
  "ansible_architecture": "$(uname -m)",
  "ansible_processor_count": $(nproc),
  "ansible_memtotal_mb": $(free -m | awk '/^Mem:/{print $2}'),
  "ansible_memfree_mb": $(free -m | awk '/^Mem:/{print $7}'),
  "ansible_default_ipv4": {
    "address": "$(ip -4 addr show | grep -Po 'inet \K[\d.]+' | grep -v 127.0.0.1 | head -1)",
    "interface": "$(ip -4 route | grep default | awk '{print $5}' | head -1)"
  },
  "ansible_tailscale": {
    "connected": $(tailscale status &>/dev/null && echo true || echo false),
    "ip": "$(tailscale ip -4 2>/dev/null || echo null)",
    "hostname": "laptop.hq"
  },
  "ansible_python": {
    "version": "$(python3 --version 2>&1 | cut -d' ' -f2)",
    "executable": "$(which python3)"
  },
  "ansible_service_mgr": "systemd",
  "ansible_pkg_mgr": "dnf",
  "ansible_selinux": {
    "status": "$(getenforce 2>/dev/null || echo 'disabled')"
  },
  "ansible_date_time": {
    "epoch": "$(date +%s)",
    "iso8601": "$(date -Iseconds)"
  },
  "laptop_specific": {
    "device_type": "laptop",
    "expected_uptime": 40,
    "roaming": true,
    "battery_powered": true,
    "gui_available": true,
    "development_environment": true
  }
}
EOF
}

# Main execution
case "${1:-}" in
    --json)
        generate_facts | jq '.' 2>/dev/null || generate_facts
        ;;
    --yaml)
        generate_facts | jq -r 'to_entries | .[] | "\(.key): \(.value)"' 2>/dev/null
        ;;
    --validate)
        echo "Validating Ansible facts..."
        if generate_facts | jq '.' &>/dev/null; then
            echo "✓ Facts are valid JSON"
            exit 0
        else
            echo "✗ Invalid facts format"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [--json|--yaml|--validate]"
        echo
        echo "Generate Ansible-compatible facts about this laptop"
        echo
        echo "Options:"
        echo "  --json     Output in JSON format (default)"
        echo "  --yaml     Output in YAML format"
        echo "  --validate Validate facts structure"
        echo
        generate_facts | jq '.' 2>/dev/null || generate_facts
        ;;
esac