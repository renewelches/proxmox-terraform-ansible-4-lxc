# proxmox-prod / openwebui-searxng

Provisions two LXC containers on Proxmox VE for Open WebUI and SearXNG. Generates the Ansible inventory at `ansible/inventory/proxmox-prod/openwebui-searxng/inventory.ini`.

## Containers

| Service    | Hostname      | Cores | RAM    | Swap   | Disk  | Port |
|------------|---------------|-------|--------|--------|-------|------|
| Open WebUI | `open-webui`  | 2     | 1.5 GB | 768 MB | 50 GB | 443  |
| SearXNG    | `searxng`     | 1     | 512 MB | 256 MB | 30 GB | 443  |

## Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values. Sensitive variables should be set via environment variables:

```bash
export TF_VAR_proxmox_api_token="terraform@pve!provider=..."
export TF_VAR_proxmox_host_default_pwd="your-password"
```

Key variables:

| Variable | Description |
|----------|-------------|
| `proxmox_nodes` | Map of node names per container (`openwebui`, `searxng`) |
| `static_ips` | Map of static IPs (`open_webui`, `searxng`) |
| `ollama_host` | URL of your remote Ollama instance |
| `template_file_id` | Proxmox LXC template (e.g. `pve-cluster:vztmpl/debian13-docker_v29-template.tar.gz`) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Generates: ansible/inventory/proxmox-prod/openwebui-searxng/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/openwebui-searxng/inventory.ini \
  ansible/deploy-openwebui-searxng.yml
```
