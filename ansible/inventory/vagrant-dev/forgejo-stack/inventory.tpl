[all]
forgejo ansible_host=127.0.0.1 ansible_port=${forgejo_port} ansible_ssh_private_key_file=${forgejo_key}

[containers]
forgejo

[forgejo]
forgejo

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
forgejo_domain=${forgejo_domain}
