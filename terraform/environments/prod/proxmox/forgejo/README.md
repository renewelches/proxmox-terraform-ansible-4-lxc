# proxmox-prod / forgejo

Provisions one LXC container on Proxmox VE for [Forgejo](https://forgejo.org/) — a self-hosted Git service. Generates the Ansible inventory at `ansible/inventory/prod/proxmox/forgejo/inventory.ini`.

The container runs Forgejo with HTTPS (TLS) and a built-in SSH server for Git operations.

## Container

| Service | Hostname | Cores | RAM | Swap | Disk | Ports |
|---------|----------|-------|-----|------|------|-------|
| Forgejo | `forgejo` | 2 | 2 GB | 1 GB | 50 GB | 443 (HTTPS), 2222 (Git SSH) |

## Prerequisites

TLS certificate and private key must be placed in `ansible/files/forgejo/` before running the playbook:

```
ansible/files/forgejo/forgejo.crt   # TLS certificate
ansible/files/forgejo/forgejo.key   # TLS private key
```

Both files must be readable by UID 1000 (Forgejo's internal `git` user).

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
| `static_ip` | Static IP for the container (without CIDR, e.g. `192.168.1.80`) |
| `forgejo_domain` | Domain name for the Forgejo instance (e.g. `forgejo.example.com`) |
| `template_file_id` | Proxmox LXC template (e.g. `pve-cluster:vztmpl/debian13-docker_v29-template.tar.gz`) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/prod/proxmox/forgejo/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/forgejo/inventory.ini \
  ansible/deploy-forgejo.yml
```

Forgejo is then accessible at `https://<forgejo_domain>`. Git SSH clone URLs use port 2222.
