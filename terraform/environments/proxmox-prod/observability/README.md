# proxmox-prod / observability

Provisions two LXC containers on Proxmox VE for the observability stack. Generates the Ansible inventory at `ansible/inventory/proxmox-prod/observability-stack/inventory.ini`.

Requires the **ai-stack** to be deployed first — the Prometheus scrape targets are the Docker metrics endpoints on the ai-stack containers.

## Containers

| Service | Hostname | Cores | RAM | Disk | Port |
|---------|----------|-------|-----|------|------|
| Prometheus | `prometheus` | 2 | 2 GB | 50 GB | 9090 |
| Grafana | `grafana` | 1 | 1 GB | 25 GB | 3000 |

## Variables

Copy `terraform.tfvars.example` to `terraform.tfvars`. Sensitive variables via environment variables:

```bash
export TF_VAR_proxmox_api_token="terraform@pve!provider=..."
export TF_VAR_proxmox_host_default_pwd="your-password"
```

Key variables:

| Variable | Description |
|----------|-------------|
| `proxmox_nodes` | Map of node names (`prometheus`, `grafana`) |
| `static_ips` | Map of static IPs (`prometheus`, `grafana`) |
| `ai_stack_ips` | IPs of ai-stack containers for Prometheus scraping (`open_webui`, `searxng`, `n8n`) |
| `template_file_id` | Proxmox LXC template |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/proxmox-prod/observability-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/observability-stack/inventory.ini \
  ansible/deploy-observability-stack.yml
```
