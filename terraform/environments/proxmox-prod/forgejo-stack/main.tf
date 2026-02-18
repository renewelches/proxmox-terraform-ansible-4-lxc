provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_tls_insecure
}

resource "proxmox_virtual_environment_container" "forgejo-container" {
  node_name = var.proxmox_node

  unprivileged = true
  features {
    nesting = true
  }

  initialization {
    hostname = "forgejo"

    user_account {
      password = var.proxmox_host_default_pwd
    }

    ip_config {
      ipv4 {
        address = "${var.static_ip}/24"
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
    dedicated = 2048
    swap      = 1024
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../../../../ansible/inventory/proxmox-prod/forgejo-stack/inventory.tpl", {
    forgejo_ip     = split("/", proxmox_virtual_environment_container.forgejo-container.initialization[0].ip_config[0].ipv4[0].address)[0]
    forgejo_domain = var.forgejo_domain
  })
  filename = "${path.module}/../../../../ansible/inventory/proxmox-prod/forgejo-stack/inventory.ini"
}
