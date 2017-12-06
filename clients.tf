resource "openstack_networking_floatingip_v2" "clients" {
  depends_on = ["openstack_compute_instance_v2.clients"]
  port_id  = "${element(openstack_networking_port_v2.clients-port.*.id, count.index)}"
  count = "${var.client_count}"
  pool  = "${var.external_network}"
}

resource "null_resource" "provision-client" {
  count = "${var.client_count}"
  depends_on = ["openstack_networking_floatingip_v2.clients"]
  connection {
    host     = "${element(openstack_networking_floatingip_v2.clients.*.address, count.index)}"
    user     = "${var.ssh_user_name}"
    private_key = "${file(var.ssh_key_file)}"
    timeout = "120s"
  }
  provisioner "file" {
    source = "etc/sources.list"
    destination = "sources.list"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cp sources.list ${var.sources_list_dest}", # if debmirror at #      "sudo apt-add-repository -y 'deb http://nova.clouds.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse'", # if debmirror at OTC is not working
      "echo Instaling python ...",
      "sudo apt-get -y update",
      "sudo apt-get -y install python",
    ]
  }
}

resource "openstack_compute_instance_v2" "clients" {
  depends_on = ["openstack_networking_router_interface_v2.interface"]
  count           = "${var.client_count}"
  name            = "${var.project}-client-${format("%02d", count.index+1)}"
  image_name      = "${var.image_name}"				#"bitnami-ceph-osdstack-7.0.22-1-linux-centos-7-x86_64-mp"
  flavor_name     = "${var.client_flavor_name}"
  key_pair        = "${openstack_compute_keypair_v2.otc.name}"
  availability_zone = "${var.availability_zone}"
  security_groups = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.name}",
    "${openstack_compute_secgroup_v2.oneprovider.name}",
  ]

  network {
    port = "${element(openstack_networking_port_v2.clients-port.*.id, count.index)}"
    uuid = "${openstack_networking_network_v2.network.id}"
    access_network = true
  }
}

resource "openstack_networking_port_v2" "clients-port" {
  count              = "${var.client_count}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.id}",
    "${openstack_compute_secgroup_v2.oneprovider.id}",
  ]
  admin_state_up     = "true"
  fixed_ip           = {
    subnet_id        = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

# resource "openstack_compute_secgroup_v2" "oneprovider" {
#   name        = "${var.project}-secgrp-oneprovider"
#   description = "Oneprovider Security Group"

#   rule {
#     from_port   = 22
#     to_port     = 22
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 80
#     to_port     = 80
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 443
#     to_port     = 443
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 53
#     to_port     = 53
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 53
#     to_port     = 53
#     ip_protocol = "udp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 5555
#     to_port     = 5555
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 5556
#     to_port     = 5556
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 6665
#     to_port     = 6665
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 6666
#     to_port     = 6666
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 7443
#     to_port     = 7443
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 8443
#     to_port     = 8443
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 8876
#     to_port     = 8876
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 8877
#     to_port     = 8877
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 9443
#     to_port     = 9443
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = -1
#     to_port     = -1
#     ip_protocol = "icmp"
#     cidr        = "0.0.0.0/0"
#   }
#   rule {
#     from_port   = 1
#     to_port     = 65535
#     ip_protocol = "tcp"
#     self        = true
#   }
# }

