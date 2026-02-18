# vagrant-dev / observability

Provisions two VirtualBox VMs via Vagrant for local development of the observability stack. Generates the Ansible inventory at `ansible/inventory/vagrant-dev/observability-stack/inventory.ini`.

The VMs connect to the AI stack VMs via the private host-only network (`192.168.56.x`). Run the `ai-stack` Vagrant environment before deploying this one.

## VMs

| Service | Hostname | vCPUs | RAM | Disk | Forwarded Port |
|---------|----------|-------|-----|------|----------------|
| Prometheus | `prometheus` | 1 | 2 GB | 20 GB | `host:9090 → guest:9090` |
| Grafana | `grafana` | 1 | 1 GB | 20 GB | `host:3000 → guest:3000` |

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Starts VMs + generates ansible/inventory/vagrant-dev/observability-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/vagrant-dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/vagrant-dev/observability-stack/inventory.ini \
  ansible/deploy-observability-stack.yml
```

## Access

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`
