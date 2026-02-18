# vagrant-dev / ai-stack

Provisions three VirtualBox VMs via Vagrant for local development of the AI stack. Generates the Ansible inventory at `ansible/inventory/vagrant-dev/ai-stack/inventory.ini`.

## VMs

| Service | Hostname | vCPUs | RAM | Disk | Forwarded Port |
|---------|----------|-------|-----|------|----------------|
| Open WebUI | `openwebui` | 2 | 1.5 GB | 50 GB | `host:8080 → guest:80` |
| SearXNG | `searxng` | 1 | 1 GB | 50 GB | `host:8081 → guest:80` |
| n8n | `n8n` | 2 | 2 GB | 50 GB | `host:5678 → guest:5678` |

Each VM uses the `cloud-image/debian-13` box with Docker provisioned on startup.

## Variables

Copy `terraform.tfvars.example` to `terraform.tfvars`:

| Variable | Description |
|----------|-------------|
| `ollama_host` | URL of your Ollama instance (accessible from the VM) |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Starts VMs + generates ansible/inventory/vagrant-dev/ai-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/vagrant-dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/vagrant-dev/ai-stack/inventory.ini \
  ansible/deploy-ai-stack.yml
```

## Access

- Open WebUI: `http://localhost:8080`
- SearXNG: `http://localhost:8081`
- n8n: `http://localhost:5678`

## Teardown

```bash
# From this directory
terraform destroy
```
