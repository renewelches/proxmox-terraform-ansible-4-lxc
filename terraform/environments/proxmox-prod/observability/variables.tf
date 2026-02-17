variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API Token, use environment variable or secure vault (e.g. terraform@pve!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS verification (set to true for self-signed certificates)"
  type        = bool
  default     = false
}

variable "proxmox_nodes" {
  description = "Target Proxmox node names per container (keys: tbd)"
  type        = map(string)
}


variable "proxmox_host_default_pwd" {
  description = "The root user password for the host"
  type        = string
  sensitive   = true
}

variable "static_ips" {
  description = "Map of static IP addresses for resources"
  type        = map(string)
}

variable "file-system" {
  description = "The default file system to be used for the container or VM"
  type        = string
  default     = "local-zfs"
}

variable "template_file_id" {
  description = "The Proxmox template file ID for LXC containers (e.g., pve-cluster:vztmpl/debian13-docker-template.tar.gz)"
  type        = string
}

variable "os_type" {
  description = "The operating system type for LXC containers (e.g., debian, ubuntu, centos)"
  type        = string
  default     = "debian"
}

variable "ai_stack_ips" {
  description = "IP addresses of ai-stack LXCs for Prometheus scrape targets"
  type = object({
    open_webui = string
    searxng    = string
    n8n        = string
  })
}
