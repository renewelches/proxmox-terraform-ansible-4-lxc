# Terraform

Terraform provisions Proxmox LXC containers and generates the Ansible inventory files. Local development uses Vagrant directly — see `vagrant/` — not Terraform.

## Structure

```
terraform/
└── environments/
    └── prod/
        └── proxmox/    # Production: Proxmox LXC containers
            ├── openwebui-searxng/
            ├── prometheus-grafana/
            ├── claude-code/
            ├── termix/
            └── forgejo/
```

Each stack directory is an independent Terraform root module with its own state. Run all Terraform commands from within the stack directory.

## Providers

| Environment  | Provider                                                                    | Version     |
| ------------ | --------------------------------------------------------------------------- | ----------- |
| proxmox-prod | [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest) | `>= 0.89.0` |

Also uses `hashicorp/local` to write the generated `inventory.ini`.

## Inventory Generation

Each `terraform apply` writes an `inventory.ini` into the corresponding `ansible/inventory/prod/proxmox/<stack>/` directory via a `local_file` resource. The path is hardcoded relative to the stack directory (`../../../../ansible/inventory/...`), so Terraform must be run from within the stack directory.

## Environment Details

### Proxmox Production Environment

All stacks in this directory provision LXC containers on Proxmox VE using the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest/docs) provider. Each stack is independently deployable with its own Terraform state.

#### Stacks

| Stack                 | Directory                                                                                                                                         | Containers          | Description                 |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | --------------------------- |
| Open WebUI + SearXNG  | [`openwebui-searxng`](environments/prod/proxmox/openwebui-searxng/) — [README](environments/prod/proxmox/openwebui-searxng/README.md)             | Open WebUI, SearXNG | Open WebUI and SearXNG      |
| Prometheus + Grafana  | [`prometheus-grafana`](environments/prod/proxmox/prometheus-grafana/) — [README](environments/prod/proxmox/prometheus-grafana/README.md)         | Prometheus, Grafana | Monitoring                  |
| Claude Code           | [`claude-code`](environments/prod/proxmox/claude-code/) — [README](environments/prod/proxmox/claude-code/README.md)                               | Claude Code         | Claude Code CLI environment |
| Termix                | [`termix`](environments/prod/proxmox/termix/) — [README](environments/prod/proxmox/termix/README.md)                                              | Termix, guacd       | Web-based terminal manager  |
| Forgejo               | [`forgejo`](environments/prod/proxmox/forgejo/) — [README](environments/prod/proxmox/forgejo/README.md)                                           | Forgejo             | Self-hosted Git service     |

#### Common Setup

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

#### Recommended Deploy Order

1. `openwebui-searxng` — core services
2. `prometheus-grafana` — independent from Terraform; Prometheus scrape targets are configured in Ansible `group_vars`
3. `claude-code` — independent, can be deployed at any time
4. `termix` — independent; requires TLS cert/key in `ansible/files/termix/` beforehand
5. `forgejo` — independent; requires TLS cert/key in `ansible/files/forgejo/` beforehand
