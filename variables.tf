### OpenStack Credentials
variable "username" {}

variable "password" {}

variable "domain_name" {}

#variable "user_no" {}

variable "tenant_name" {
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
variable "project" {
#   default = "od"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "ssh_key_file" {
#  default = "~/.ssh/id_rsa"
  default = "keys/id_rsa"
}

### VM (Instance) Settings
variable "ceph-mgt_count" {
  default = "1"
}

variable "ceph-mon_count" {
  default = "1"
}

variable "ceph-osd_count" {
  default = "3"
}

variable "flavor_name" {
  default = "h1.large.4"
#  default = "hl1.8xlarge.8" # Setting this flavor may require setting vol_type and vol_prefix
}

variable "image_name" {
  default = "Community_Ubuntu_16.04_TSI_latest"
}

variable "availability_zone" {
  default = "eu-de-01"
}

variable "vol_size" {
  default = "100"
}

variable "vol_type" {
  default = "SSD"
#  default = "co-p1"
}

variable "vol_prefix" {
  default = "/dev/xvd"
#  default = "/dev/vd"
}

variable "disks-per-osd_count" {
  default = "2"
}

variable "client_count" {
  default = "1"
}

variable "client_flavor_name" {
  default = "h1.large.4"
}

variable "provider_count" {
  default = "1"
}

variable "provider_flavor_name" {
  default = "h1.xlarge.4"
}

variable "dnszone" {
#  default = ""
}

variable "email" {
#  default = ""
}

variable "onezone" {
  default = "https://onedata.hnsc.otc-service.com"
}

variable "token" {
#  default = ""
}

variable "sources_list_dest" {
#  default = "/dev/null"
  default = "/etc/apt/sources.list"   # Use this if OTC debmirror has problems
}

variable "atoken" {
}

variable "storage_type" {
#  default = "posix"
  default = "ceph"
}
