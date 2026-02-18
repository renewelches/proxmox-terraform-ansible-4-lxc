# Proxmox Production Environment

All stacks in this directory provision LXC containers on Proxmox VE using the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider. Each stack is independently deployable with its own Terraform state.

## Stacks

| Stack | Directory | Containers | Description |
|-------|-----------|------------|-------------|
| AI Stack | [`ai-stack/`](ai-stack/) | Open WebUI, SearXNG, n8n | AI and automation services |
| Observability | [`observability/`](observability/) | Prometheus, Grafana | Monitoring for the AI stack |
| Forgejo | [`forgejo-stack/`](forgejo-stack/) | Forgejo | Self-hosted Git service with HTTPS |
| k3s | [`k3s/`](k3s/) | Open WebUI, SearXNG, n8n | ⚠️ Work in progress |

## Common Setup

All stacks share the same Proxmox credentials. Set these once as environment variables:

```bash
export TF_VAR_proxmox_api_token="terraform@pve!provider=..."
export TF_VAR_proxmox_host_default_pwd="your-password"
```

SSH agent must be running with your key loaded for Ansible to connect:

```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

## Recommended Deploy Order

1. `ai-stack` — core services
2. `observability` — depends on ai-stack IPs for Prometheus scraping
3. `forgejo-stack` — independent, can be deployed at any time
