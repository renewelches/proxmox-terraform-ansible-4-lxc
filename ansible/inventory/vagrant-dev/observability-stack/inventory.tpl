[all]
prometheus ansible_host=127.0.0.1 ansible_port=${prometheus_port} ansible_ssh_private_key_file=${prometheus_key}
grafana   ansible_host=127.0.0.1 ansible_port=${grafana_port} ansible_ssh_private_key_file=${grafana_key}

[containers]
prometheus
grafana

[prometheus]
prometheus

[grafana]
grafana

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
prometheus_ip=${prometheus_ip}
ai_stack_ip_openwebui=${ai_stack_ip_openwebui}
ai_stack_ip_searxng=${ai_stack_ip_searxng}
ai_stack_ip_n8n=${ai_stack_ip_n8n}
