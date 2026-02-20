#!/usr/bin/env bash
# Generates ansible/inventory/dev/vagrant-vb/observability-stack/inventory.ini from vagrant ssh-config.
# Run from this directory (vagrant/vagrant-vb/observability/).
#
# Usage: ./gen-inventory.sh
# Requires the ai-stack to already be running (IPs 192.168.56.3-5 are hardcoded).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_OUT="${SCRIPT_DIR}/../../../ansible/inventory/dev/vagrant-vb/observability-stack/inventory.ini"

get_ssh_field() {
  vagrant ssh-config "$1" 2>/dev/null | awk -v f="$2" '$1 == f {print $2}'
}

echo "Reading SSH config from vagrant..."
PROM_PORT=$(get_ssh_field prometheus Port)
PROM_KEY=$(get_ssh_field prometheus IdentityFile)
GRF_PORT=$(get_ssh_field grafana Port)
GRF_KEY=$(get_ssh_field grafana IdentityFile)

mkdir -p "$(dirname "$INVENTORY_OUT")"
cat > "$INVENTORY_OUT" << EOF
[all]
prometheus ansible_host=127.0.0.1 ansible_port=${PROM_PORT} ansible_ssh_private_key_file=${PROM_KEY}
grafana   ansible_host=127.0.0.1 ansible_port=${GRF_PORT} ansible_ssh_private_key_file=${GRF_KEY}

[containers]
prometheus
grafana

[prometheus]
prometheus

[grafana]
grafana

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
prometheus_ip=192.168.56.6
ai_stack_ip_openwebui=192.168.56.3
ai_stack_ip_searxng=192.168.56.4
ai_stack_ip_n8n=192.168.56.5
EOF

echo "Inventory written to: ${INVENTORY_OUT}"
