.PHONY: help install join status test sync-config update-hq

help:
	@echo "Fedora Laptop Mesh Node Management"
	@echo "  make install     - Install Tailscale"
	@echo "  make join        - Join the mesh network"
	@echo "  make status      - Show current mesh status"
	@echo "  make test        - Test connectivity to hub"
	@echo "  make sync-config - Pull latest config from mesh-infra"
	@echo "  make update-hq   - Update mesh-infra with our status"

install:
	@echo "Installing Tailscale (requires sudo)..."
	@./scripts/install-tailscale.sh

join:
	@echo "Joining mesh network..."
	@./scripts/join-mesh.sh

status:
	@echo "=== Mesh Network Status ==="
	@if command -v tailscale >/dev/null 2>&1; then \
		echo "Tailscale Status:"; \
		sudo tailscale status || echo "Not connected"; \
		echo; \
		echo "IP Address:"; \
		sudo tailscale ip -4 2>/dev/null || echo "No IP assigned"; \
	else \
		echo "Tailscale not installed. Run 'make install' first."; \
	fi

test:
	@echo "Testing connectivity to hub..."
	@if command -v tailscale >/dev/null 2>&1; then \
		sudo tailscale ping -c 3 hetzner-hq || echo "Hub unreachable"; \
	else \
		echo "Tailscale not installed"; \
	fi

sync-config:
	@echo "Syncing configuration from mesh-infra..."
	@if [ -d "../mesh-infra" ]; then \
		cd ../mesh-infra && git pull; \
		echo "✓ Mesh-infra updated"; \
	else \
		echo "mesh-infra repository not found at ../mesh-infra"; \
	fi

update-hq:
	@echo "Updating mesh-infra with laptop status..."
	@./scripts/report-status.sh