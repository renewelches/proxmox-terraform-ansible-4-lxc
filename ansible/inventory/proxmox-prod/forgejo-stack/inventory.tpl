[all]
forgejo ansible_host=${forgejo_ip}

[containers]
forgejo

[forgejo]
forgejo

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3.13
