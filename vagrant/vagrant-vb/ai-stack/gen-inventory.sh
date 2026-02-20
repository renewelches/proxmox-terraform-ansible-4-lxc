#!/usr/bin/env bash
# Generates ansible/inventory/dev/vagrant-vb/ai-stack/inventory.ini from vagrant ssh-config.
# Run from this directory (vagrant/vagrant-vb/ai-stack/).
#
# Usage: ./gen-inventory.sh <ollama_host>
#   Example: ./gen-inventory.sh http://192.168.1.100:11434

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_OUT="${SCRIPT_DIR}/../../../ansible/inventory/dev/vagrant-vb/ai-stack/inventory.ini"

OLLAMA_HOST="${1:-}"
if [ -z "$OLLAMA_HOST" ]; then
  echo "Usage: $0 <ollama_host>" >&2
  echo "  Example: $0 http://192.168.1.100:11434" >&2
  exit 1
fi

get_ssh_field() {
  vagrant ssh-config "$1" 2>/dev/null | awk -v f="$2" '$1 == f {print $2}'
}

echo "Reading SSH config from vagrant..."
OW_PORT=$(get_ssh_field openwebui Port)
OW_KEY=$(get_ssh_field openwebui IdentityFile)
SX_PORT=$(get_ssh_field searxng Port)
SX_KEY=$(get_ssh_field searxng IdentityFile)
N8N_PORT=$(get_ssh_field n8n Port)
N8N_KEY=$(get_ssh_field n8n IdentityFile)

mkdir -p "$(dirname "$INVENTORY_OUT")"
cat > "$INVENTORY_OUT" << EOF
[all]
n8n ansible_host=127.0.0.1 ansible_port=${N8N_PORT} ansible_ssh_private_key_file=${N8N_KEY}
open-webui ansible_host=127.0.0.1 ansible_port=${OW_PORT} ansible_ssh_private_key_file=${OW_KEY}
searxng ansible_host=127.0.0.1 ansible_port=${SX_PORT} ansible_ssh_private_key_file=${SX_KEY}

[containers]
n8n
open-webui
searxng

[n8n]
n8n

[open-webui]
open-webui

[searxng]
searxng

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
ollama_host=${OLLAMA_HOST}
EOF

echo "Inventory written to: ${INVENTORY_OUT}"
