# proxmox-prod / n8n

Provisions one LXC container on Proxmox VE for [n8n](https://n8n.io/) — a workflow automation platform. Generates the Ansible inventory at `ansible/inventory/prod/proxmox/n8n/inventory.ini`.

## Container

| Service | Hostname | Cores | RAM | Swap | Disk | Port |
|---------|----------|-------|-----|------|------|------|
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
| `proxmox_node` | Proxmox node name to deploy onto |
| `static_ip` | Static IP for the container (without CIDR, e.g. `192.168.1.59`) |
| `template_file_id` | Proxmox LXC template (e.g. `pve-cluster:vztmpl/debian13-docker_v29-template.tar.gz`) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/prod/proxmox/n8n/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/n8n/inventory.ini \
  ansible/deploy-n8n.yml
```

n8n is then accessible at `http://<n8n-ip>:5678`.
