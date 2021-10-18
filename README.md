# Intersight Service for Terraform Demo - Basic DCN & VMware Networking Automation

[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/cisco-apjc-cloud-se/ist-vcenter-dcnm)

## Overview
This is a simpler version of the “Integrated DC Network, Infrastructure & Security Automation” use case that focuses solely on DCNM and vCenter networking automation, specifically the automation of a DCNM-based VXLAN EVPN fabric connecting to a VMware ESXi cluster with a Distributed Virtual Switch.

## Requirements
The Infrastructure-as-Code environment will require the following:
* GitHub Repository for Terraform plans, modules and variables as JSON files
* Terraform Cloud for Business account with a workspace associated to the GitHub repository above
* Cisco Intersight (SaaS) platform account with sufficient Advantage licensing
* An Intersight Assist appliance VM connected to the Intersight account above

This example will then use the following on-premise domain managers. These will need to be fully commissioned and a suitable user account provided for Terraform to use for provisioning.
* Cisco Data Center Network Manager (DCNM)
* VMware vCenter

## Assumptions
The DC Networking module makes the following assumptions:
* An existing Nexus 9000 switch based VXLAN fabric has already been deployed and that it is actively managed through a DCNM instance.
* The DCNM server is accessible by HTTPS from the Intersight Assist VM.
* An existing VRF is available to use for new L3 VXLAN networks.  Any dynamic routing/peering to external devices (including firewalls) have already be configured as necessary.
* Suitable IP subnets (at least /29) are available to be assigned to each new L3 network.
* Suitable VLAN IDs are available to be assigned to each new L3 network.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * DCNM account username (dcnm_user)
  * DCNM account password (dcnm_password)
  *	DCNM URL (dcnm_url)

The vCenter module makes the following assumptions:
* A group of VMware host servers are configured as a single VMware server cluster within a logical VMware Data Center, managed from an existing vCenter instance.  
* The vCenter server is accessible by HTTPS from the Intersight Assist VM.
* VMware host servers have commissioned and are physically patched to trunked switch ports (or VPCs) on the VXLAN fabric access (leaf) switches.  The configuration of the switch ports is not included in this example, though is covered in other DCNM example use cases.
* A distributed virtual switch (DVS) has been configured across all servers in the cluster and their physical ethernet uplink ports.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * vCenter account username (vcenter_user)
  * vCenter account password (vcenter_password)
  * vCenter server IP/FQDN (vcenter_server)


## Link to Github Repositories
https://github.com/cisco-apjc-cloud-se/ist-vcenter-dcnm

## Steps to Deploy Use Case
1.	In GitHub, create a new, or clone the example GitHub repository(s)
2.	Customize the examples Terraform files & input variables as required
3.	In Intersight, configure a Terraform Cloud target with suitable user account and token
4.	In Intersight, configure a Terraform Agent target with suitable managed host URLs/IPs.  This list of managed hosts must include the IP addresses for the DCNM server as well as access to common GitHub domains in order to download hosted Terraform providers.  This will create a Terraform Cloud Agent pool and register this to Terraform Cloud.
5.	In Terraform Cloud for Business, create a new Terraform Workspace and associate to the GitHub repository.
6.	In Terraform Cloud for Business, configure the workspace to the use the Terraform Agent pool configured from Intersight.
7.	In Terraform Cloud for Business, configure the necessary user account variables for the DCNM servers.

## Workarounds ##

*October 2021*
In this example, both VLAN IDs and VXLAN IDs have been explicity set.  These are optional parameters and can be removed and left to DCNM to inject these dynamically from the fabrics' resource pools.  However if you chose to use DCNM to do this, Terraform MUST be configured to use a "parallelism" value of 1.  This ensures Terraform will only attempt to configure one resource at a time allowing DCNM to allocate IDs from the pool sequentially.  

Typically the parallelism would be set in the Terraform cloud workspace environment variables section using the variable name "TFE_PARALLELISM" and value of "1", however this variable is NOT used by Terraform Cloud Agents.  Instead the variables "TF_CLI_ARGS_plan" and "TF_CLI_ARGS_apply" must be used with a value of "-parallelism=1"


*October 2021* Due to an issue with the Terraform Provider (version 1.0.0) and DCNM API (11.5(3)) the "dcnm_network" resource will not deploy Layer 3 SVIs.  This is due to a defaul parameter not being correctly set in the API call.  Instead, the Network will be deployed as if the template has the "Layer 2 Only" checkbox set.

There are two workarouds for this
1. After deploying the network(s), edit the network from the DCNM GUI then immediately save.  This will set the correct default parameters and these networks can be re-deployed.
2. Instead of the using the "Default_Network_Universal" template, clone and modify it as below.  Make sure to set the correct template name in the terraform plan under the dcnm_network resource.   Please note that the tag value of 12345 must also be explicity set.

    Original Lines #119-#123
    ```
    if ($$isLayer2Only$$ != "true") {
      interface Vlan$$vlanId$$
       if ($$intfDescription$$ != "") {
        description $$intfDescription$$
       }
    ```
    Modified Lines #119-#125
    ```
    if ($$isLayer2Only$$ == "true"){
     }
    else {
    interface Vlan$$vlanId$$
     if ($$intfDescription$$ != "") {
      description $$intfDescription$$
     }
    ```

## Example Input Variables ###
```json
{
  "vcenter_dc": "CPOC-HX",
  "vcenter_dvs": "CPOC-SE-VC-HX",
  "dcnm_fabric": "DC3",
  "dcnm_vrf": "GUI-VRF-1",
  "cluster_interfaces": {
    "DC3-LEAF-1": {
      "name": "DC3-LEAF-1",
      "attach": true,
      "switch_ports": [
        "Ethernet1/11"
      ]
    },
    "DC3-LEAF-2": {
      "name": "DC3-LEAF-2",
      "attach": true,
      "switch_ports": [
        "Ethernet1/11"
      ]
    }
  },
  "cluster_networks": {
    "IST-NETWORK-1": {
      "name": "IST-NETWORK-1",
      "description": "Terraform Intersight Demo Network #1",
      "ip_subnet": "192.168.1.1/24",
      "vni_id": 32101,
      "vlan_id": 2101,
      "deploy": true
    },
    "IST-NETWORK-2": {
      "name": "IST-NETWORK-2",
      "description": "Terraform Intersight Demo Network #2",
      "ip_subnet": "192.168.2.1/24",
      "vni_id": 32102,
      "vlan_id": 2102,
      "deploy": true
    }
  }
}
```

## Execute Deployment
In Terraform Cloud for Business, queue a new plan to trigger the initial deployment.  Any future changes to pushed to the GitHub repository will automatically trigger a new plan deployment.

## Results
If successfully executed, the Terraform plan will result in the following configuration:

* New Layer 3 VXLAN network(s) each with the following configuration:
  * Name
  * Anycast Gateway IPv4 Address/Mask
  * VXLAN VNI ID
  * VLAN ID

* New Distributed Port Groups for each VXLAN network defined above
  * Name
  * VLAN ID


## Expected Day 2 Changes
Changes to the variables defined in the input variable files will result in dynamic, stateful update to DCNM. For example,

* Adding a Network entry will create a new DCNM Network template instance and deploy this network to the associated switches, as well as trunk to the associated switch interfaces.
* Adding a Network entry will also create a matching distributed port group on the specific VMware distribute switch.
* Adding a new host to the VMware host cluster and distributed switch will ensure the hew host inherits the distributed port groups.  Adding the new hosts' interfaces to the "cluster_interfaces" variable will ensure that all necessary VLANs are trunked to the new host.
