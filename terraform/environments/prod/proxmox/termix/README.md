# proxmox-prod / termix

Provisions one LXC container on Proxmox VE for [Termix](https://docs.termix.site/) — a web-based terminal manager. Generates the Ansible inventory at `ansible/inventory/prod/proxmox/termix/inventory.ini`.

The container runs two Docker containers: **termix** (web UI, HTTPS on port 8443) and **guacd** (Guacamole daemon for enhanced terminal support), connected via a private Docker network.

## Container

| Service | Hostname | Cores | RAM | Swap | Disk | Ports |
|---------|----------|-------|-----|------|------|-------|
| Termix | `termix` | 2 | 2 GB | 1 GB | 20 GB | 8080 (HTTP redirect), 8443 (HTTPS) |

## Prerequisites

TLS certificate and private key must be placed in `ansible/files/termix/` before running the playbook:

```text
ansible/files/termix/termix.crt   # TLS certificate for termix.grumples.home
ansible/files/termix/termix.key   # TLS private key
```

Both files are git-ignored.

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
| `static_ip` | Static IP for the container (without CIDR, e.g. `192.168.1.70`) |
| `template_file_id` | Proxmox LXC template (e.g. `pve-cluster:vztmpl/debian13-docker_v29-template.tar.gz`) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/prod/proxmox/termix/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/termix/inventory.ini \
  ansible/deploy-termix.yml
```

Termix is then accessible at `https://termix.grumples.home` (port 8443).
