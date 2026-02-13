[all]
n8n ansible_host=127.0.0.1 ansible_port=${n8n_port} ansible_ssh_private_key_file=${n8n_key}
open-webui ansible_host=127.0.0.1 ansible_port=${openwebui_port} ansible_ssh_private_key_file=${openwebui_key}
searxng ansible_host=127.0.0.1 ansible_port=${searxng_port} ansible_ssh_private_key_file=${searxng_key}

[containers]
n8n
open-webui
searxng

[n8n]
n8n

[open-webui]
open-webui

[searxng]
searxng

[all:vars]
ansible_user=vagrant
ansible_python_interpreter=/usr/bin/python3.13
ollama_host=${ollama_host}
