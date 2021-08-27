### DCNM Variables

variable "dcnm_user" {
  type = string
}

variable "dcnm_password" {
  type = string
}

variable "dcnm_url" {
  type = string
}

variable "dcnm_fabric" {
  type = string
}

variable "dcnm_vrf" {
  type = string
}

### Common Variables

variable "cluster_interfaces" {
  type = map(object({
    name = string
    attach = bool
    switch_ports = list(string)
  }))
}


variable "cluster_networks" {
  type = map(object({
    name = string
    description = string
    ip_subnet = string
    vni_id = number
    vlan_id = number
    deploy = bool
  }))
}
