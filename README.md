# Proxmox Terraform + Ansible Configuration

This repository contains Terraform and Ansible configuration for deploying containerized applications using LXC containers (production) or Vagrant VMs (development).

- **Terraform** provisions the hosts and generates the Ansible inventory
- **Ansible** deploys and manages the Docker containers

## What This Deploys

The project is organized into three independently deployable stacks:

### AI Stack

Three Docker-enabled containers running:

1. **Open WebUI** (`open-webui`) — Web interface for Ollama AI models
   - 2 CPU cores, 1.5 GB RAM, 50 GB storage
   - Connected to a remote Ollama instance
   - Integrates with SearXNG for web search capabilities

2. **SearXNG** (`searxng`) — Privacy-respecting metasearch engine
   - 1 CPU core, 512 MB RAM, 30 GB storage
   - Pre-configured for integration with Open WebUI

3. **n8n** (`n8n`) — Workflow automation platform
   - 2 CPU cores, 6 GB RAM, 50 GB storage
   - Persistent data storage with Docker volumes and SQLite

### Observability Stack

Two Docker-enabled containers for monitoring the AI stack:

1. **Prometheus** (`prometheus`) — Metrics collection and monitoring
   - 2 CPU cores, 2 GB RAM, 50 GB storage
   - Scrapes Docker metrics from all AI stack containers on port 9323
   - Accessible on port 9090

2. **Grafana** (`grafana`) — Visualization and dashboards
   - 1 CPU core, 1 GB RAM, 25 GB storage
   - Auto-provisioned with Prometheus as a data source
   - Accessible on port 3000

### Forgejo Stack

One Docker-enabled container for self-hosted Git:

1. **Forgejo** (`forgejo`) — Self-hosted Git service
   - 2 CPU cores, 2 GB RAM, 50 GB storage
   - HTTPS on port 3000 with a self-signed certificate
   - Git SSH on port 2222
   - SQLite database

All stacks configure Docker to expose metrics (`"metrics-addr": "0.0.0.0:9323"` in `/etc/docker/daemon.json`), enabling Prometheus to scrape container metrics across all hosts.

## Environments

| Aspect | proxmox-prod | vagrant-dev |
|--------|-------------|-------------|
| Infrastructure | Proxmox LXC containers | Vagrant VirtualBox VMs |
| Provider | `bpg/proxmox` | `bmatcuk/vagrant` |
| Networking | Static IPs | Port forwarding (localhost) |
| SSH User | root | vagrant |
| SSH Auth | SSH agent key | Vagrant-generated keys |
| Base Image | `debian13-docker_v29-template.tar.gz` | `cloud-image/debian-13` box |

## Prerequisites

- Terraform >= 1.0
- Ansible >= 2.9 with `community.docker` collection
- For **proxmox-prod**: Proxmox VE server with API access and custom Debian 13 Docker template
- For **vagrant-dev**: VirtualBox and Vagrant with `vagrant-disksize` plugin

## Project Structure

```
.
├── terraform/                             # → terraform/README.md
│   └── environments/
│       ├── proxmox-prod/                  # → terraform/environments/proxmox-prod/README.md
│       │   ├── ai-stack/                  # → .../ai-stack/README.md
│       │   ├── observability/             # → .../observability/README.md
│       │   ├── forgejo-stack/             # → .../forgejo-stack/README.md
│       │   └── k3s/                       # → .../k3s/README.md  (WIP)
│       └── vagrant-dev/                   # → terraform/environments/vagrant-dev/README.md
│           ├── ai-stack/                  # → .../ai-stack/README.md
│           ├── observability/             # → .../observability/README.md
│           └── forgejo-stack/             # → .../forgejo-stack/README.md
└── ansible/                               # → ansible/README.md
    ├── deploy-ai-stack.yml
    ├── deploy-observability-stack.yml
    ├── deploy-forgejo-stack.yml
    ├── templates/
    │   ├── openwebui/docker.env.j2
    │   ├── prometheus/prometheus.yml.j2
    │   └── grafana/datasources.yml.j2
    ├── files/
    │   ├── searxng/settings.yml
    │   └── forgejo/                       # TLS cert + key (key is git-ignored)
    └── inventory/
        ├── proxmox-prod/                  # → ansible/inventory/proxmox-prod/README.md
        │   ├── ansible.cfg
        │   ├── ai-stack/
        │   ├── observability-stack/
        │   └── forgejo-stack/
        └── vagrant-dev/                   # → ansible/inventory/vagrant-dev/README.md
            ├── ansible.cfg
            ├── ai-stack/
            ├── observability-stack/
            └── forgejo-stack/
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
5. Rename the resulting file to match your `template_file_id`.
6. Verify: `ls -la /var/lib/vz/template/cache/`

### 3. Configure Variables

Each stack has its own `terraform.tfvars.example`. Copy it to `terraform.tfvars` in the same directory:

```bash
cd terraform/environments/proxmox-prod/ai-stack    # or any other stack
cp terraform.tfvars.example terraform.tfvars
# Edit with your environment-specific values
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

Each stack is deployed independently. Commands must be run from within the stack directory for Terraform, and from the repo root for Ansible.

**AI Stack**

```bash
cd terraform/environments/proxmox-prod/ai-stack   # or vagrant-dev/ai-stack
terraform init && terraform apply
# Generates: ansible/inventory/proxmox-prod/ai-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/ai-stack/inventory.ini \
  ansible/deploy-ai-stack.yml
```

**Observability Stack** (deploy after AI stack)

```bash
cd terraform/environments/proxmox-prod/observability   # or vagrant-dev/observability
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/observability-stack/inventory.ini \
  ansible/deploy-observability-stack.yml
```

**Forgejo Stack**

```bash
cd terraform/environments/proxmox-prod/forgejo-stack   # or vagrant-dev/forgejo-stack
terraform init && terraform apply
# Generates: ansible/inventory/proxmox-prod/forgejo-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/forgejo-stack/inventory.ini \
  ansible/deploy-forgejo-stack.yml
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

If using self-signed certificates on the Proxmox API, set in your `terraform.tfvars`:

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
ls -la /var/lib/vz/template/cache/
```

## Additional Resources

- [bpg/proxmox Provider Documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [SearXNG Documentation](https://docs.searxng.org/)
- [n8n Documentation](https://docs.n8n.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Forgejo Documentation](https://forgejo.org/docs/latest/)
