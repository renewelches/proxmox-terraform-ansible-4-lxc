# Ansible

Ansible deploys Docker containers onto the hosts provisioned by Terraform. All playbooks are run from the repo root using the per-environment `ansible.cfg`.

## Playbooks

| Playbook                          | Stacks              | Description                          |
|-----------------------------------|---------------------|--------------------------------------|
| `deploy-openwebui-searxng.yml`    | openwebui-searxng   | Open WebUI, SearXNG                  |
| `deploy-prometheus-grafana.yml`   | prometheus-grafana  | Prometheus, Grafana                  |
| `deploy-claude-code.yml`          | claude-code         | Claude Code CLI, git, tmux           |
| `deploy-termix.yml`               | termix              | Termix web terminal + guacd (HTTPS)  |
| `deploy-forgejo.yml`              | forgejo             | Forgejo self-hosted Git (HTTPS + SSH)|
| `deploy-n8n.yml`                  | n8n                 | n8n workflow automation              |

Every playbook runs a common preparation play on all hosts that:

1. Updates and upgrades apt packages
2. Installs `python3-docker` (required by the `community.docker` modules)
3. Configures Docker to expose metrics on `0.0.0.0:9323` (for Prometheus scraping)
4. Restarts Docker

## Inventory

Inventories are generated — do not edit `inventory.ini` files by hand. For prod, Terraform generates them via `templatefile()`. For dev, the Vagrantfile trigger writes them automatically after `vagrant up`.

```text
inventory/
├── prod/proxmox/
│   ├── ansible.cfg                       # StrictHostKeyChecking=accept-new, SSH agent auth
│   ├── openwebui-searxng/
│   ├── prometheus-grafana/
│   │   └── group_vars/all.yml            # Prometheus scrape targets (edit per environment)
│   ├── claude-code/
│   ├── termix/
│   └── forgejo/
└── dev/
    ├── ansible.cfg                       # StrictHostKeyChecking=no, per-host key auth
    ├── openwebui-searxng/
    ├── prometheus-grafana/
    │   └── group_vars/all.yml            # Prometheus scrape targets (edit per environment)
    ├── claude-code/
    ├── termix/
    └── forgejo/
```

## Templates and Files

| Path                                     | Used by                     | Purpose                          |
|------------------------------------------|-----------------------------|----------------------------------|
| `templates/openwebui/docker.env.j2`      | deploy-openwebui-searxng    | Open WebUI env vars (SearXNG URL)|
| `templates/prometheus/prometheus.yml.j2` | deploy-prometheus-grafana   | Prometheus scrape config         |
| `templates/grafana/datasources.yml.j2`   | deploy-prometheus-grafana   | Grafana Prometheus datasource    |
| `files/searxng/settings.yml`             | deploy-openwebui-searxng    | SearXNG search engine config     |
| `files/termix/termix.crt` + `.key`       | deploy-termix               | TLS cert/key (git-ignored)       |
| `files/forgejo/forgejo.crt` + `.key`     | deploy-forgejo              | TLS cert/key (git-ignored)       |

## Usage

```bash
# Install required collection
ansible-galaxy collection install community.docker

# Run a playbook (proxmox-prod example)
ANSIBLE_CONFIG=ansible/inventory/prod/proxmox/ansible.cfg \
  ansible-playbook -i ansible/inventory/prod/proxmox/<stack>/inventory.ini \
  ansible/<playbook>.yml

# Run a playbook (vagrant-dev example)
ANSIBLE_CONFIG=ansible/inventory/dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/dev/<stack>/inventory.ini \
  ansible/<playbook>.yml
```
