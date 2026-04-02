# Proxmox Terraform + Ansible Configuration

This repository contains Terraform and Ansible configuration for deploying containerized applications using LXC containers (production) or Vagrant VMs (development).

- **Terraform** provisions the hosts and generates the Ansible inventory
- **Ansible** deploys and manages the Docker containers

## What This Deploys

The project is organized into independently deployable stacks:

### openwebui-searxng

Two Docker-enabled containers running:

1. **Open WebUI** (`open-webui`) — Web interface for Ollama AI models
   - 2 CPU cores, 1.5 GB RAM, 50 GB storage
   - Connected to a remote Ollama instance
   - Integrates with SearXNG for web search capabilities

2. **SearXNG** (`searxng`) — Privacy-respecting metasearch engine
   - 1 CPU core, 512 MB RAM, 30 GB storage
   - Pre-configured for integration with Open WebUI

### n8n

One Docker-enabled container running:

1. **n8n** (`n8n`) — Workflow automation platform
   - 2 CPU cores, 6 GB RAM, 50 GB storage
   - Nginx TLS proxy on ports 80/443; requires cert/key in `ansible/files/n8n/` before deployment
   - Persistent data storage via Docker volume and SQLite

### prometheus-grafana

Two Docker-enabled containers for monitoring:

1. **Prometheus** (`prometheus`) — Metrics collection and monitoring
   - 2 CPU cores, 2 GB RAM, 50 GB storage
   - Scrapes Docker metrics on port 9323 from targets defined in `group_vars/all.yml`
   - Accessible on port 9090

2. **Grafana** (`grafana`) — Visualization and dashboards
   - 1 CPU core, 1 GB RAM, 25 GB storage
   - Auto-provisioned with Prometheus as a data source
   - Accessible on port 3000

### claude-code

One container for running Claude Code CLI:

1. **Claude Code** (`claude-code`) — Anthropic's Claude Code CLI with git and tmux
   - 2 CPU cores, 2 GB RAM, 20 GB storage
   - Requires `ANTHROPIC_API_KEY` set on the container after deployment

### termix

One Docker-enabled container running:

1. **Termix** (`termix`) — Web-based remote terminal access (backed by Apache Guacamole)
   - 2 CPU cores, 2 GB RAM, 20 GB storage
   - HTTPS on port 443; requires cert/key in `ansible/files/termix/` before deployment
   - Runs `termix` + `guacd` containers on a shared Docker network

### forgejo

One Docker-enabled container running:

1. **Forgejo** (`forgejo`) — Self-hosted Git service
   - 2 CPU cores, 2 GB RAM, 50 GB storage
   - HTTPS web UI on port 443, Git SSH on port 2222
   - Requires TLS certificate/key in `ansible/files/forgejo/` before deployment
   - Set `FORGEJO_DOMAIN` env var before running `vagrant up`

### minio

One Docker-enabled container running:

1. **MinIO** (`minio`) — S3-compatible object storage
   - 2 CPU cores, 2 GB RAM, 100 GB storage
   - S3 API on port 9000, web console on port 9001
   - HTTPS with TLS; requires cert/key in `ansible/files/minio/` before deployment
   - Credentials configured via `minio_root_user` / `minio_root_password` inventory vars

All stacks configure Docker to expose metrics (`"metrics-addr": "0.0.0.0:9323"` in `/etc/docker/daemon.json`), enabling Prometheus to scrape container metrics across all hosts.

## Environments

The **Vagrant environment** (`vagrant/`) is intended for local development and testing of the Ansible playbooks. It spins up lightweight VMs on your local machine (VirtualBox) that mirror the production topology, letting you iterate on Ansible roles and configuration without touching the Proxmox cluster. Once the playbooks are validated locally, they can be applied to production unchanged — only the inventory differs.

| Aspect         | proxmox-prod                          | vagrant-dev                               |
| -------------- | ------------------------------------- | ----------------------------------------- |
| Infrastructure | Proxmox LXC containers                | Vagrant VirtualBox/UTM VMs                |
| Purpose        | Production workloads                  | Local Ansible development & testing       |
| Networking     | Static IPs                            | Port forwarding (localhost)               |
| SSH User       | root                                  | vagrant                                   |
| SSH Auth       | SSH agent key                         | Vagrant-generated keys                    |
| Base Image     | `debian13-docker_v29-template.tar.gz` | `cloud-image/debian-13`                   |

## Prerequisites

- Terraform >= 1.0
- Ansible >= 2.9 with `community.docker` collection
- For **proxmox-prod**: Proxmox VE server with API access and custom Debian 13 Docker template
- For **vagrant-dev**: VirtualBox and Vagrant with `vagrant-disksize` plugin

## Project Structure

```text
.
├── terraform/                             # → terraform/README.md
│   └── environments/
│       └── prod/
│           └── proxmox/
│               ├── openwebui-searxng/     # → .../openwebui-searxng/README.md
│               ├── prometheus-grafana/    # → .../prometheus-grafana/README.md
│               ├── claude-code/           # → .../claude-code/README.md
│               ├── termix/               # → .../termix/README.md
│               ├── forgejo/              # → .../forgejo/README.md
│               ├── n8n/                  # → .../n8n/README.md
│               └── minio/               # → .../minio/README.md
├── vagrant/                               # VirtualBox dev environment
│   ├── openwebui-searxng/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up
│   ├── prometheus-grafana/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up
│   ├── claude-code/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up
│   ├── termix/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up
│   ├── forgejo/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up (requires FORGEJO_DOMAIN)
│   ├── n8n/
│   │   └── Vagrantfile                    # auto-generates inventory.ini on vagrant up
│   └── minio/
│       └── Vagrantfile                    # auto-generates inventory.ini on vagrant up (requires minio.crt/minio.key)
└── ansible/                               # → ansible/README.md
    ├── deploy-openwebui-searxng.yml
    ├── deploy-prometheus-grafana.yml
    ├── deploy-claude-code.yml
    ├── deploy-termix.yml
    ├── deploy-forgejo.yml
    ├── deploy-n8n.yml
    ├── deploy-minio.yml
    ├── templates/
    │   ├── openwebui/docker.env.j2
    │   ├── prometheus/prometheus.yml.j2
    │   └── grafana/datasources.yml.j2
    ├── files/
    │   ├── searxng/settings.yml
    │   ├── termix/                        # termix.crt + termix.key (git-ignored)
    │   ├── forgejo/                       # forgejo.crt + forgejo.key (git-ignored)
    │   ├── grafana/                       # grafana.crt + grafana.key (git-ignored)
    │   └── minio/                         # minio.crt + minio.key (git-ignored)
    └── inventory/
        ├── prod/
        │   └── proxmox/                   # → ansible/inventory/prod/proxmox/README.md
        │       ├── ansible.cfg
        │       ├── openwebui-searxng/
        │       ├── prometheus-grafana/
        │       │   └── group_vars/all.yml # Prometheus scrape targets
        │       ├── claude-code/
        │       ├── termix/
        │       ├── forgejo/
        │       ├── n8n/
        │       └── minio/
        └── dev/                           # → ansible/inventory/dev/README.md
            ├── ansible.cfg
            ├── openwebui-searxng/
            ├── prometheus-grafana/
            │   └── group_vars/all.yml     # Prometheus scrape targets
            ├── claude-code/
            ├── termix/
            ├── forgejo/
            ├── n8n/
            └── minio/
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
cd terraform/environments/proxmox-prod/openwebui-searxng    # or any other stack
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

#### Deploy: AI Stack

```bash
cd terraform/environments/prod/proxmox/openwebui-searxng   # or vagrant/openwebui-searxng
terraform init && terraform apply
# Generates: ansible/inventory/prod/proxmox/openwebui-searxng/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/openwebui-searxng/inventory.ini \
  ansible/deploy-openwebui-searxng.yml
```

#### Deploy: Observability Stack

```bash
cd terraform/environments/prod/proxmox/prometheus-grafana   # or vagrant/prometheus-grafana
terraform init && terraform apply
# Generates: ansible/inventory/prod/proxmox/prometheus-grafana/inventory.ini

# Edit scrape targets before running Ansible:
#   ansible/inventory/prod/proxmox/prometheus-grafana/group_vars/all.yml

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/prometheus-grafana/inventory.ini \
  ansible/deploy-prometheus-grafana.yml
```

#### Deploy: Claude Code Stack

```bash
cd terraform/environments/prod/proxmox/claude-code   # or vagrant/claude-code
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/claude-code/inventory.ini \
  ansible/deploy-claude-code.yml

# After deploying, set the API key on the container:
#   export ANTHROPIC_API_KEY=sk-ant-...
```

#### Deploy: Termix Stack

Requires TLS cert/key in `ansible/files/termix/` beforehand.

```bash
cd terraform/environments/prod/proxmox/termix   # or vagrant/termix
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/termix/inventory.ini \
  ansible/deploy-termix.yml
```

#### Deploy: Forgejo Stack

Requires TLS cert/key in `ansible/files/forgejo/` beforehand.

```bash
cd terraform/environments/prod/proxmox/forgejo   # or vagrant/forgejo
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/forgejo/inventory.ini \
  ansible/deploy-forgejo.yml
```

#### Deploy: n8n Stack

```bash
cd terraform/environments/prod/proxmox/n8n   # or vagrant/n8n
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/n8n/inventory.ini \
  ansible/deploy-n8n.yml
```

#### Deploy: MinIO Stack

Requires TLS cert/key in `ansible/files/minio/` beforehand.

```bash
cd terraform/environments/prod/proxmox/minio   # or vagrant/minio
terraform init && terraform apply

# From repo root
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/minio/inventory.ini \
  ansible/deploy-minio.yml
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
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Forgejo Documentation](https://forgejo.org/docs/latest/)
- [MinIO Documentation](https://min.io/docs/minio/linux/index.html)
