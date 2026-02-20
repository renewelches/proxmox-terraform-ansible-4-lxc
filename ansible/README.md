# Ansible

Ansible deploys Docker containers onto the hosts provisioned by Terraform. All playbooks are run from the repo root using the per-environment `ansible.cfg`.

## Playbooks

| Playbook | Stacks | Description |
|----------|--------|-------------|
| `deploy-ai-stack.yml` | ai-stack | Open WebUI, SearXNG, n8n |
| `deploy-observability-stack.yml` | observability | Prometheus, Grafana |

Every playbook runs a common preparation play on all hosts that:
1. Updates and upgrades apt packages
2. Installs `python3-docker` (required by the `community.docker` modules)
3. Configures Docker to expose metrics on `0.0.0.0:9323` (for Prometheus scraping)
4. Restarts Docker

## Inventory

Inventories are generated — do not edit `inventory.ini` files by hand. For prod, Terraform generates them via `templatefile()`. For dev, run `gen-inventory.sh` after `vagrant up`.

```
inventory/
├── prod/proxmox/
│   ├── ansible.cfg              # StrictHostKeyChecking=accept-new, SSH agent auth
│   ├── ai-stack/
│   └── observability-stack/
└── dev/vagrant-vb/  (and vagrant-utm/)
    ├── ansible.cfg              # StrictHostKeyChecking=no, per-host key auth
    ├── ai-stack/
    └── observability-stack/
```

## Templates and Files

| Path | Used by | Purpose |
|------|---------|---------|
| `templates/openwebui/docker.env.j2` | deploy-ai-stack | Open WebUI env vars (SearXNG URL) |
| `templates/prometheus/prometheus.yml.j2` | deploy-observability-stack | Prometheus scrape config |
| `templates/grafana/datasources.yml.j2` | deploy-observability-stack | Grafana Prometheus datasource |
| `files/searxng/settings.yml` | deploy-ai-stack | SearXNG search engine config |

## Usage

```bash
# Install required collection
ansible-galaxy collection install community.docker

# Run a playbook (proxmox-prod example)
ANSIBLE_CONFIG=ansible/inventory/proxmox-prod/ansible.cfg \
  ansible-playbook -i ansible/inventory/proxmox-prod/<stack>/inventory.ini \
  ansible/<playbook>.yml

# Run a playbook (vagrant-dev example)
ANSIBLE_CONFIG=ansible/inventory/vagrant-dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/vagrant-dev/<stack>/inventory.ini \
  ansible/<playbook>.yml
```
