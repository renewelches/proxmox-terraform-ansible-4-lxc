# vagrant-dev / forgejo-stack

Provisions a single VirtualBox VM via Vagrant for local development of the Forgejo stack. Generates the Ansible inventory at `ansible/inventory/vagrant-dev/forgejo-stack/inventory.ini`.

## VM

| Service | Hostname | vCPUs | RAM | Disk | Forwarded Ports |
|---------|----------|-------|-----|------|-----------------|
| Forgejo | `forgejo` | 2 | 2 GB | 50 GB | `host:3000 → guest:3000` (HTTPS), `host:2222 → guest:2222` (git SSH) |

Uses the `cloud-image/debian-13` box with Docker provisioned on startup.

## No Variables Required

This stack has no configurable variables. The inventory is generated automatically after `terraform apply`.

## Deploy

```bash
# From this directory
terraform init
terraform plan
terraform apply
# Starts VM + generates ansible/inventory/vagrant-dev/forgejo-stack/inventory.ini

# From repo root
ANSIBLE_CONFIG=ansible/inventory/vagrant-dev/ansible.cfg \
  ansible-playbook -i ansible/inventory/vagrant-dev/forgejo-stack/inventory.ini \
  ansible/deploy-forgejo-stack.yml
```

## Access

Forgejo runs with HTTPS using the production self-signed certificate. The cert is valid for the configured `forgejo_domain` / `192.168.86.210`, so your browser will show a certificate warning on localhost.

- Forgejo web UI: `https://localhost:3000` (accept the cert warning)
- Git SSH: `ssh://git@localhost:2222`

## Notes

- The Vagrant SSH port also uses 2222 internally (via VirtualBox NAT), which is the standard behaviour for the `cloud-image/debian-13` box. Ansible connects on port 2222 to reach the VM's own SSH daemon. The Docker container maps its internal SSH to the same host port — this is fine because Docker's iptables rules handle the forwarding without conflicting with Ansible's connection.
- The git SSH forwarding via `localhost:2222` may not function in Vagrant due to VirtualBox NAT rule priority. This is expected — the Vagrant environment is intended for testing deployment, not full git operations.

## Teardown

```bash
# From this directory
terraform destroy
```
