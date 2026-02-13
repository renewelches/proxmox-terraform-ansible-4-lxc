provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}

resource "proxmox_virtual_environment_container" "open-webui-container" {
  node_name = var.proxmox_nodes.openwebui

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "open-webui"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ips.open_webui}/24" #fixed IP address
        #address = "dhcp"
        gateway = "192.168.86.1"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.file-system
    size         = 50
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 1536
  }

}

resource "proxmox_virtual_environment_container" "searxng-container" {
  node_name = var.proxmox_nodes.searxng

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "searxng"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ips.searxng}/24"
        #address = "dhcp"
        gateway = "192.168.86.1"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.file-system
    size         = 30
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 1024
  }
}



resource "proxmox_virtual_environment_container" "n8n-container" {
  node_name    = var.proxmox_nodes.n8n
  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "n8n"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ips.n8n}/24"
        #address = "dhcp"
        gateway = "192.168.86.1"
      }
    }
  }

  network_interface {
    name = "eth0"
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  disk {
    datastore_id = var.file-system
    size         = 50
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 6144
  }
}

# Generate Ansible inventory from container IPs
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../../ansible/inventory/proxmox-prod/inventory.tpl", {
    containers = {
      "n8n"        = split("/", proxmox_virtual_environment_container.n8n-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "open-webui" = split("/", proxmox_virtual_environment_container.open-webui-container.initialization[0].ip_config[0].ipv4[0].address)[0]
      "searxng"    = split("/", proxmox_virtual_environment_container.searxng-container.initialization[0].ip_config[0].ipv4[0].address)[0]
    }
    ollama_host = var.ollama_host
  })
  filename = "${path.module}/../../../../ansible/inventory/proxmox-prod/inventory.ini"
}

