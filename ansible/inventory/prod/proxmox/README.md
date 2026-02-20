# ansible/inventory/proxmox-prod

Ansible configuration and inventory templates for the Proxmox production environment.

## ansible.cfg

```ini
[ssh_connection]
ssh_args = -o StrictHostKeyChecking=accept-new
```

Trusts new host keys on first connect. Uses the SSH agent for authentication (`ssh-add` your key before running playbooks).

## Inventories

Each stack has its own subdirectory with an `inventory.tpl` (Terraform template) and a generated `inventory.ini` (git-ignored):

| Stack | Ansible user | Host auth |
|-------|-------------|-----------|
| ai-stack | `root` | SSH agent |
| observability-stack | `root` | SSH agent |

Generated inventories use direct static IPs. Example:

```ini
[all]
open-webui ansible_host=192.168.86.200

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3.13
```
