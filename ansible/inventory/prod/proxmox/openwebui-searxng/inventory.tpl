[all]
%{ for name, ip in containers ~}
${name} ansible_host=${ip}
%{ endfor ~}

[containers]
%{ for name, ip in containers ~}
${name}
%{ endfor ~}

[open-webui]
open-webui

[searxng]
searxng

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3.13
ollama_host=${ollama_host}
