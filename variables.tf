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
  default = "daro2"
}

variable "ssh_user_name" {
  default = "ubuntu"
}

variable "ssh_key_file" {
  default = "~/.ssh/id_rsa"
}

### VM (Instance) Settings
variable "ceph-mgt_count" {
  default = "1"
}

variable "ceph-mon_count" {
  default = "3"
}

variable "ceph-osd_count" {
  default = "3"
}

variable "flavor_name" {
  default = "s1.medium"
}

variable "image_name" {
  default = "Community_Ubuntu_16.04_TSI_latest"
}
