# Terraform

Terraform provisions the infrastructure (LXC containers or Vagrant VMs) and generates the Ansible inventory files.

## Structure

```
terraform/
└── environments/
    ├── proxmox-prod/    # Production: Proxmox LXC containers
    │   ├── ai-stack/
    │   ├── observability/
    │   ├── forgejo-stack/
    │   └── k3s/         # Work in progress
    └── vagrant-dev/     # Development: VirtualBox VMs via Vagrant
        ├── ai-stack/
        ├── observability/
        └── forgejo-stack/
```

Each stack directory is an independent Terraform root module with its own state. Run all Terraform commands from within the stack directory.

## Providers

| Environment | Provider | Version |
|-------------|----------|---------|
| proxmox-prod | [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest) | `>= 0.89.0` |
| vagrant-dev | [`bmatcuk/vagrant`](https://registry.terraform.io/providers/bmatcuk/vagrant/latest) | `~> 4.1.0` |

Both environments also use `hashicorp/local` to write the generated `inventory.ini`.

## Inventory Generation

Each `terraform apply` writes an `inventory.ini` into the corresponding `ansible/inventory/<env>/<stack>/` directory via a `local_file` resource. The path is hardcoded relative to the stack directory (`../../../../ansible/inventory/...`), so Terraform must be run from within the stack directory.

## Environment Details

- [proxmox-prod →](environments/proxmox-prod/)
- [vagrant-dev →](environments/vagrant-dev/)
