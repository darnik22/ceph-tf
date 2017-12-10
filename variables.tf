### OpenStack Credentials
variable "otc_username" {}

variable "otc_password" {}

variable "otc_domain_name" {}

variable "otc_tenant_name" {
  default = "eu-de"
}

variable "endpoint" {
  default = "https://iam.eu-de.otc.t-systems.com:443/v3"
}

### OTC Specific Settings
variable "external_network" {
  default = "admin_external_net"
}

### Project Settings
# The name of the project. It is used to prefix VM names. It should be unique among
# OTC as it is used to create names of VMs. The first provider will have the following
# FQDN: ${project}-op-01.${dnszone} publicly accessible.
variable "project" {
#   default = "od"
}

# The user name for loggin into the VMs.
variable "ssh_user_name" {
  default = "ubuntu"
}

# Path to the ssh key. The key should not be password protected.
# The mkkeys.sh script can be used to generate the a new key pair if the directory
# "keys" does not exist or is epmpty.
# The key will be copied to the management node.
variable "ssh_key_file" {
  default = "keys/id_rsa"
}

### VM (Instance) Settings
# This is the number of management nodes. It should be 1.
variable "ceph-mgt_count" {
  default = "1"
}

# The number of monitors of Ceph cluster. 
variable "ceph-mon_count" {
  default = "1"
}

# The number of VM for running OSDs.
variable "ceph-osd_count" {
  default = "3"
}

# The flavor name used for Ceph monitors and OSDs. 
variable "flavor_name" {
  default = "h1.large.4"
#  default = "hl1.8xlarge.8" # Setting this flavor may require setting vol_type and vol_prefix
}

# The image name used fro all instances
variable "image_name" {
  default = "Community_Ubuntu_16.04_TSI_latest"
}

# Availability zone 
variable "availability_zone" {
  default = "eu-de-01"
}

# The size of elastic volumes which will be attached to the OSDs. The size is given in GB.
variable "vol_size" {
  default = "100"
}

# The type volume. It specifies the performance of a volume. "SSD" maps to "Ultra High I/O".
variable "vol_type" {
  default = "SSD"
#  default = "co-p1"
}

# The number of disks to attach to each VM for running OSDs. The raw Ceph total capacity
# will be (osd_count * disks-per-osd_count * vol_size) GB.
variable "disks-per-osd_count" {
  default = "2"
}

# The number of client VMs
variable "client_count" {
  default = "1"
}

# The flavor for clients
variable "client_flavor_name" {
  default = "h1.large.4"
}

# The number of oneprovider nodes
variable "provider_count" {
  default = "1"
}

# The flavor for provider nodes
variable "provider_flavor_name" {
  default = "h1.xlarge.4"
}

# The public DNS zone to be created in OTC. There should be a registred domain of
# the same name under your control. The domain should use the following nameservers:
#   - ns1.open-telekom-cloud.com
#   - ns2.open-telekom-cloud.com
variable "dnszone" {
#  default = ""
}

# A valid email will be needed when creating cerificates
variable "email" {
#  default = ""
}

# The onezone managing your space  - the one which is going to be supported by the
# oneprovider 
variable "onezone" {
  default = "https://onedata.hnsc.otc-service.com"
}

# Your onedata request support token 
variable "support_token" {
#  default = ""
}

# Your onedata access token
variable "access_token" {
  # default = ""
}

#### Internal usage variables ####
variable "sources_list_dest" {
#  default = "/dev/null"
  default = "/etc/apt/sources.list"   # Use this if OTC debmirror has problems
}

variable "storage_type" {
#  default = "posix"
  default = "ceph"
}

# The disk device naming (prefix) for the given flavor.
variable "vol_prefix" {
  default = "/dev/xvd"
#  default = "/dev/vd"
}

