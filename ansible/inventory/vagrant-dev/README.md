# ansible/inventory/vagrant-dev

Ansible configuration and inventory templates for the Vagrant development environment.

## ansible.cfg

```ini
[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o IdentitiesOnly=yes
```

Disables host key checking (safe for local VMs). Forces use of the per-VM private key via `IdentitiesOnly=yes`.

## Inventories

Each stack has its own subdirectory with an `inventory.tpl` (Terraform template) and a generated `inventory.ini` (git-ignored):

| Stack | Ansible user | Host auth |
|-------|-------------|-----------|
| ai-stack | `vagrant` | Per-VM Vagrant private key |
| observability-stack | `vagrant` | Per-VM Vagrant private key |
| forgejo-stack | `vagrant` | Per-VM Vagrant private key |

Generated inventories use `127.0.0.1` with the auto-assigned SSH port and the Vagrant-generated private key path. Example:

```ini
[all]
forgejo ansible_host=127.0.0.1 ansible_port=2222 ansible_ssh_private_key_file=/path/to/.vagrant/.../private_key

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
```
