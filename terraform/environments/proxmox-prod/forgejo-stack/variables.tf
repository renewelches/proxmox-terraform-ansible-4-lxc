variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token (e.g., terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (set to true for self-signed certificates)"
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Target Proxmox node name for the Forgejo container"
  type        = string
}

variable "proxmox_host_default_pwd" {
  description = "The root user password for the container"
  type        = string
  sensitive   = true
}

variable "static_ip" {
  description = "Static IP address for the Forgejo LXC container (without CIDR)"
  type        = string
}

variable "file-system" {
  description = "The default file system to be used for the container"
  type        = string
  default     = "local-zfs"
}

variable "template_file_id" {
  description = "The Proxmox template file ID for LXC containers (e.g., pve-cluster:vztmpl/debian13-docker-template.tar.gz)"
  type        = string
}

variable "os_type" {
  description = "The operating system type for LXC containers (e.g., debian, ubuntu)"
  type        = string
  default     = "debian"
}
