# ansible/inventory/vagrant-dev

Ansible configuration and inventory templates for the Vagrant development environment.

## ansible.cfg

```ini
[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o IdentitiesOnly=yes
```

Disables host key checking (safe for local VMs). Forces use of the per-VM private key via `IdentitiesOnly=yes`.

## Inventories

Each stack has its own subdirectory with a generated `inventory.ini` (git-ignored):

| Stack | Ansible user | Host auth |
| ------- | ------------- | ----------- |
| ai-stack | `vagrant` | Per-VM Vagrant private key |
| observability-stack | `vagrant` | Per-VM Vagrant private key |
| claude-code | `vagrant` | Per-VM Vagrant private key |
| termix | `vagrant` | Per-VM Vagrant private key |
| forgejo | `vagrant` | Per-VM Vagrant private key |

`inventory.ini` is generated automatically by a `config.trigger.after :up` Ruby block in each stack's `Vagrantfile`. It fires after the last VM comes up and uses Vagrant's internal SSH API to resolve each VM's dynamic port and private key path. No manual script is needed.

For the ai-stack, set `OLLAMA_HOST` before running `vagrant up`:

```bash
OLLAMA_HOST=http://192.168.1.100:11434 vagrant up
```

Generated inventories use `127.0.0.1` with the auto-assigned SSH port and the Vagrant-generated private key path. Example:

```ini
[all]
open-webui ansible_host=127.0.0.1 ansible_port=2222 ansible_ssh_private_key_file=/path/to/.vagrant/.../private_key

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
```
