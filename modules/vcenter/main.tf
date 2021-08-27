terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

### vSphere ESXi Provider
provider "vsphere" {
  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

### Existing Data Sources
data "vsphere_datacenter" "dc" {
  name          = var.vcenter_dc
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vcenter_dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

### Build New Distribute Port Group(s)
resource "vsphere_distributed_port_group" "dpg" {
  for_each                        = var.cluster_networks

  name                            = each.value.name
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = each.value.vlan_id
}
