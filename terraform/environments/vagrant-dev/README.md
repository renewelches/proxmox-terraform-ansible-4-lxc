# Vagrant Development Environment

All stacks in this directory provision VirtualBox VMs using the [`bmatcuk/vagrant`](https://github.com/bmatcuk/terraform-provider-vagrant) provider. Each stack is independently deployable with its own Terraform state.

VMs use the `cloud-image/debian-13` Vagrant box and are provisioned with Docker on startup. Port forwarding gives host access; a host-only private network (`192.168.56.x`) allows inter-VM communication.

## Stacks

| Stack | Directory | VMs | Host Ports |
|-------|-----------|-----|------------|
| AI Stack | [`ai-stack/`](ai-stack/) | Open WebUI, SearXNG, n8n | 8080, 8081, 5678 |
| Observability | [`observability/`](observability/) | Prometheus, Grafana | 9090, 3000 |
| Forgejo | [`forgejo-stack/`](forgejo-stack/) | Forgejo | 3000 (HTTPS), 2222 (git SSH) |

## Prerequisites

- VirtualBox
- Vagrant
- `vagrant plugin install vagrant-disksize` (required for disk resizing)

## Notes

- Stacks are designed to run independently — running all at once may cause port conflicts (e.g. Grafana and Forgejo both default to host port 3000).
- The Ansible `ansible_python_interpreter` is set to `/usr/bin/python3.13`, which matches the `cloud-image/debian-13` box.
- Vagrant SSH credentials (private key path, port) are written into the generated `inventory.ini` automatically by Terraform.
