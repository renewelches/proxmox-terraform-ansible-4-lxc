[all]
minio ansible_host=${ip}

[containers]
minio

[minio]
minio

[all:vars]
ansible_user=root
ansible_python_interpreter=/usr/bin/python3.13
minio_root_user=${minio_root_user}
minio_root_password=${minio_root_password}
