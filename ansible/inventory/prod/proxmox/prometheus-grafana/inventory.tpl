[all]
%{ for name, ip in containers ~}
${name} ansible_host=${ip}
%{ endfor ~}

[containers]
prometheus
grafana

[prometheus]
prometheus

[grafana]
grafana

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3.13
prometheus_ip=${containers.prometheus}
grafana_ip=${containers.grafana}
