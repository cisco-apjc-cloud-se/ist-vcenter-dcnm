### vCenter Variables

variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type = string
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_dc" {
  type = string
}

variable "vcenter_dvs" {
  type = string
}

variable "dcnm_networks" {
}

# ### Common Variables
#
# variable "cluster_networks" {
#   type = map(object({
#     name = string
#     description = string
#     ip_subnet = string
#     vni_id = number
#     vlan_id = number
#     deploy = bool
#   }))
# }
