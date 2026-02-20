# proxmox-prod / ai-stack

Provisions three LXC containers on Proxmox VE for the AI stack. Generates the Ansible inventory at `ansible/inventory/proxmox-prod/ai-stack/inventory.ini`.

## Containers

| Service | Hostname | Cores | RAM | Swap | Disk | Port |
|---------|----------|-------|-----|------|------|------|
| Open WebUI | `open-webui` | 2 | 1.5 GB | 768 MB | 50 GB | 80 |
| SearXNG | `searxng` | 1 | 512 MB | 256 MB | 30 GB | 80 |
| n8n | `n8n` | 2 | 6 GB | 3 GB | 50 GB | 5678 |

## Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values. Sensitive variables should be set via environment variables:

```bash
export TF_VAR_proxmox_api_token="terraform@pve!provider=..."
export TF_VAR_proxmox_host_default_pwd="your-password"
```

Key variables:

| Variable | Description |
|----------|-------------|
| `proxmox_nodes` | Map of node names per container (`openwebui`, `searxng`, `n8n`) |
| `static_ips` | Map of static IPs (`open_webui`, `searxng`, `n8n`) |
| `ollama_host` | URL of your remote Ollama instance |
| `template_file_id` | Proxmox LXC template (e.g. `pve-cluster:vztmpl/debian13-docker_v29-template.tar.gz`) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/proxmox-prod/ai-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/ai-stack/inventory.ini \
  ansible/deploy-ai-stack.yml
```
