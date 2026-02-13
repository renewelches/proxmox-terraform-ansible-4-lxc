# Proxmox Terraform + Ansible Configuration

This repository contains Terraform and Ansible configuration for deploying containerized applications using LXC containers (production) or Vagrant VMs (development).

- **Terraform** provisions the hosts and generates the Ansible inventory
- **Ansible** deploys and manages the Docker containers

## What This Deploys

Three Docker-enabled containers running:

1. **Open WebUI** (`open-webui`) - Web interface for Ollama AI models
   - 2 CPU cores, 1.5GB RAM, 20GB storage
   - Connected to a remote Ollama instance
   - Integrates with SearXNG for web search capabilities

2. **SearXNG** (`searxng`) - Privacy-respecting metasearch engine
   - 1 CPU core, 1GB RAM, 50GB storage
   - Pre-configured for integration with Open WebUI

3. **n8n** (`n8n`) - Workflow automation platform
   - 2 CPU cores, 6GB RAM, 50GB storage
   - Persistent data storage with Docker volumes and SQLite

## Environments

| Aspect | proxmox-prod | vagrant-dev |
|--------|-------------|-------------|
| Infrastructure | Proxmox LXC containers | Vagrant VirtualBox VMs |
| Provider | `bpg/proxmox` | `bmatcuk/vagrant` |
| Networking | Static IPs | Port forwarding (localhost) |
| SSH User | root | vagrant |
| SSH Auth | SSH agent key | Vagrant-generated keys |
| Base Image | `debian13-docker-template.tar.gz` | `cloud-image/debian-13` box |

## Prerequisites

- Terraform >= 1.0
- Ansible >= 2.9 with `community.docker` collection
- For **proxmox-prod**: Proxmox VE server with API access and custom Debian 13 Docker template
- For **vagrant-dev**: VirtualBox and Vagrant installed

## Project Structure

```
.
├── terraform/
│   └── environments/
│       ├── proxmox-prod/
│       │   ├── ai-stack/              # Production: Proxmox LXC containers
│       │   │   ├── main.tf
│       │   │   ├── variables.tf
│       │   │   ├── outputs.tf
│       │   │   ├── versions.tf
│       │   │   └── terraform.tfvars.example
│       │   └── observability/         # Observability stack (Proxmox only)
│       │       ├── main.tf
│       │       └── variables.tf
│       └── vagrant-dev/
│           └── ai-stack/              # Development: Vagrant VirtualBox VMs
│               ├── main.tf
│               ├── variables.tf
│               ├── outputs.tf
│               ├── versions.tf
│               ├── terraform.tfvars.example
│               ├── openwebui/Vagrantfile
│               ├── searxng/Vagrantfile
│               └── n8n/Vagrantfile
└── ansible/
    ├── deploy-containers.yml      # Shared playbook for both environments
    ├── templates/
    │   └── openwebui/
    │       └── docker.env.j2      # Open WebUI environment config (Jinja2)
    ├── files/
    │   └── searxng/
    │       └── settings.yml       # SearXNG search engine configuration
    └── inventory/
        ├── proxmox-prod/
        │   ├── ansible.cfg
        │   └── inventory.tpl      # Terraform template → inventory.ini
        └── vagrant-dev/
            ├── ansible.cfg
            └── inventory.tpl      # Terraform template → inventory.ini
```

## Setup

### 1. Configure Proxmox API Token (proxmox-prod only)

Create a dedicated API token in Proxmox with required permissions:

```bash
# Create user and API token
pveum user add terraform@pve
pveum user token add terraform@pve terraform-token --privsep=0

# Grant necessary permissions
pveum role add TerraformRole -privs "VM.Allocate VM.Config.Disk VM.Config.Memory VM.Config.CPU VM.Config.Network VM.Config.Options Datastore.AllocateSpace Datastore.Audit Sys.Modify Sys.Audit"
pveum acl modify / --user terraform@pve --role TerraformRole

# Or use PVEAdmin for simpler setup
pveum acl modify / --user terraform@pve --role PVEAdmin
```

**Note**: You need at minimum `Sys.Modify` permission to avoid HTTP 403 errors when creating containers.

### 2. Prepare the Container Template (proxmox-prod only)

1. Create a template based on a running LXC container with Docker installed and your SSH key provisioned for the root user.
2. Stop the container.
3. Remove the network interface.
4. `vzdump 100 --mode stop --compress gzip --dumpdir /var/lib/vz/template/cache` (replace `100` with the actual container ID).
5. Rename the resulting file to `debian13-docker-template.tar.gz`.
6. Verify: `ls -la /var/lib/vz/template/cache/debian13-docker-template.tar.gz`

### 3. Configure Variables

Each environment has its own `terraform.tfvars.example`. Copy it to `terraform.tfvars` in the same directory:

```bash
# For proxmox-prod
cd terraform/environments/proxmox-prod/ai-stack
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Proxmox API details, static IPs, etc.

# For vagrant-dev
cd terraform/environments/vagrant-dev/ai-stack
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your ollama_host URL
```

Use environment variables for sensitive data:

```bash
export TF_VAR_proxmox_api_token="your-token"
export TF_VAR_proxmox_host_default_pwd="your-password"
```

One way to set these variables on a Mac is by following [Securing Proxmox API Tokens with Apple Keychain](https://blog.renewelches.com/2025/12/09/proxmox-terraform-keychain/).

### 4. Install Ansible Docker Collection

```bash
ansible-galaxy collection install community.docker
```

### 5. Deploy

**Step 1: Provision hosts with Terraform**

```bash
# Choose your environment
cd terraform/environments/vagrant-dev/ai-stack   # or proxmox-prod/ai-stack

terraform init
terraform plan
terraform apply
```

This creates the hosts and generates `ansible/inventory/<env>/inventory.ini`.

**Step 2: Deploy Docker containers with Ansible**

```bash
# From the repo root — choose the matching inventory
ANSIBLE_CONFIG=ansible/inventory/vagrant-dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/vagrant-dev/inventory.ini ansible/deploy-containers.yml

# Or for production
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/inventory.ini ansible/deploy-containers.yml
```

### 6. Set Up SSH Agent (proxmox-prod only)

```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

## Troubleshooting

### Permission Denied (HTTP 403)

If you see `Permission check failed (/, Sys.Modify)`:

```bash
pveum acl modify / --user terraform@pve --role PVEAdmin
```

### TLS Certificate Issues

If using self-signed certificates, set in your `terraform.tfvars`:

```hcl
proxmox_tls_insecure = true
```

### SSH Connection Issues

Ensure your SSH key is loaded:

```bash
ssh-add -l  # List loaded keys
ssh-add ~/.ssh/id_rsa  # Add if not loaded
```

### Container Template Not Found

Verify the template exists in Proxmox storage:

```bash
ls -la /var/lib/vz/template/cache/debian13-docker-template.tar.gz
```

## Additional Resources

- [bpg/proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [SearXNG Documentation](https://docs.searxng.org/)
- [n8n Documentation](https://docs.n8n.io/)
