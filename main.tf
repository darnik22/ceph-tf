resource "openstack_networking_floatingip_v2" "ceph-mgt" {
  depends_on = ["openstack_compute_instance_v2.ceph-mgt"]
  port_id  = "${element(openstack_networking_port_v2.mgt-port.*.id, count.index)}"
  count = "${var.ceph-mgt_count}"
  pool  = "${var.external_network}"
}

resource "openstack_networking_floatingip_v2" "ceph-osds" {
  depends_on = ["openstack_compute_instance_v2.ceph-osds"]
  port_id  = "${element(openstack_networking_port_v2.osds-port.*.id, count.index)}"
  count = "${var.ceph-osd_count}"
  pool  = "${var.external_network}"
}

resource "openstack_networking_floatingip_v2" "ceph-mons" {
  depends_on = ["openstack_compute_instance_v2.ceph-mons"]
  port_id  = "${element(openstack_networking_port_v2.mons-port.*.id, count.index)}"
  count = "${var.ceph-mon_count}"
  pool  = "${var.external_network}"
}

resource "openstack_compute_instance_v2" "ceph-mgt" {
  depends_on = ["openstack_networking_router_interface_v2.interface"]
  count           = "${var.ceph-mgt_count}"
  name            = "${var.project}-ceph-mgt${format("%02d", count.index+1)}"
  image_name      = "${var.image_name}"				#"bitnami-ceph-osdstack-7.0.22-1-linux-centos-7-x86_64-mp"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${openstack_compute_keypair_v2.otc.name}"
  availability_zone = "${var.availability_zone}"
  security_groups = [
    "${openstack_compute_secgroup_v2.secgrp_jmp.name}",
    "${openstack_compute_secgroup_v2.secgrp_ceph.name}"
  ]
  network {
    port = "${element(openstack_networking_port_v2.mgt-port.*.id, count.index)}"
    uuid = "${openstack_networking_network_v2.network.id}"
    access_network = true
  }
}

resource "openstack_networking_port_v2" "mgt-port" {
  count              = "${var.ceph-mgt_count}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = [
    "${openstack_compute_secgroup_v2.secgrp_jmp.id}",
    "${openstack_compute_secgroup_v2.secgrp_ceph.id}",
  ]
  admin_state_up     = "true"
  fixed_ip           = {
    subnet_id        = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

resource "null_resource" "provision-osd" {
  count = "${var.ceph-osd_count}"
  depends_on = ["openstack_networking_floatingip_v2.ceph-osds"]
  connection {
    host     = "${element(openstack_networking_floatingip_v2.ceph-osds.*.address, count.index)}"
    user     = "${var.ssh_user_name}"
    private_key = "${file(var.ssh_key_file)}"
    timeout = "30s"
  }
  provisioner "remote-exec" {
    inline = [
      "echo Instaling python ...",
      "sudo apt-get -y update",
      "sudo apt-get -y install python",
    ]
  }
  provisioner "remote-exec" {
    when = "destroy"
    on_failure = "continue"
    inline = [
      "echo Halting...",
      "sudo halt -p",
    ]
  }
}

resource "null_resource" "provision-mon" {
  count = "${var.ceph-mon_count}"
  depends_on = ["openstack_networking_floatingip_v2.ceph-mons"]
  connection {
    host     = "${element(openstack_networking_floatingip_v2.ceph-mons.*.address, count.index)}"
    user     = "${var.ssh_user_name}"
    private_key = "${file(var.ssh_key_file)}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install python",
    ]
  }
}

resource "null_resource" "provision-mgt" {
  depends_on = ["openstack_networking_floatingip_v2.ceph-mgt","null_resource.provision-osd","null_resource.provision-mon"]
  provisioner "local-exec" {
    command = "./local-setup.sh ${var.project} ${var.ceph-mon_count} ${var.ceph-osd_count}"
  }
  triggers {
    cluster_instance_ids = "${join(",", openstack_networking_floatingip_v2.ceph-mgt.*.address)}"
  }
  connection {
      host     = "${openstack_networking_floatingip_v2.ceph-mgt.address}"
      user     = "${var.ssh_user_name}"
      private_key = "${file(var.ssh_key_file)}"
  }
  provisioner "file" {
    source = "keys/"
    destination = "~/.ssh"
  }  
  provisioner "file" {
    source = "playbooks.tgz"
    destination = "playbooks.tgz"
  }
  provisioner "file" {
    content = "${join("\n", formatlist("%s %s", openstack_compute_instance_v2.ceph-osds.*.access_ip_v4, openstack_compute_instance_v2.ceph-osds.*.name))}\n${join("\n", formatlist("%s %s", openstack_compute_instance_v2.ceph-mons.*.access_ip_v4, openstack_compute_instance_v2.ceph-mons.*.name))}\n${join("\n", formatlist("%s %s", openstack_compute_instance_v2.ceph-mgt.*.access_ip_v4, openstack_compute_instance_v2.ceph-mgt.*.name))}\n"
    destination = "hosts.tmp"
  }
  provisioner "file" {
    source = "etc.tgz"
    destination = "etc.tgz"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 600 .ssh/id_rsa",
      "sudo sh -c 'cat hosts.tmp >> /etc/hosts'",
      "sudo apt-get -y update",
      "sudo apt-get -y install software-properties-common",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-get -y update",
      "sudo apt-get -y install ansible",
      "tar zxvf playbooks.tgz",
      "tar zxvf etc.tgz",
      "sudo cp etc/ansible-hosts /etc/ansible/hosts",
      "sudo cp etc/ssh_config /etc/ssh/ssh_config",
      #      "ansible-playbook playbooks/otc/otc-snat-setup.yml",
      "ansible-playbook playbooks/myceph/myceph.yml --extra-vars \"osd_disks=${var.disks-per-osd_count}\"",
#      "ansible-playbook playbooks/ceph-ansible/site.yml",
    ]
  }
}

resource "openstack_compute_instance_v2" "ceph-osds" {
  depends_on = ["openstack_networking_router_interface_v2.interface"]
  count           = "${var.ceph-osd_count}"
  name            = "${var.project}-ceph-osd${format("%02d", count.index+1)}"
  image_name      = "${var.image_name}"				#"bitnami-ceph-osdstack-7.0.22-1-linux-centos-7-x86_64-mp"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${openstack_compute_keypair_v2.otc.name}"
  availability_zone = "${var.availability_zone}"
  security_groups = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.name}"
  ]

  network {
    port = "${element(openstack_networking_port_v2.osds-port.*.id, count.index)}"
    uuid = "${openstack_networking_network_v2.network.id}"
    access_network = true
  }
}

resource "openstack_networking_port_v2" "osds-port" {
  count              = "${var.ceph-osd_count}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.id}",
  ]
  admin_state_up     = "true"
  fixed_ip           = {
    subnet_id        = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

resource "openstack_compute_instance_v2" "ceph-mons" {
  depends_on = ["openstack_networking_router_interface_v2.interface"]
  count           = "${var.ceph-mon_count}"
  name            = "${var.project}-ceph-mon${format("%02d", count.index+1)}"
  image_name      = "${var.image_name}"				#"bitnami-ceph-osdstack-7.0.22-1-linux-centos-7-x86_64-mp"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${openstack_compute_keypair_v2.otc.name}"
  availability_zone = "${var.availability_zone}"
  security_groups = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.name}"
  ]

  network {
    port = "${element(openstack_networking_port_v2.mons-port.*.id, count.index)}"
    uuid = "${openstack_networking_network_v2.network.id}"
    access_network = true
  }
}

resource "openstack_networking_port_v2" "mons-port" {
  count              = "${var.ceph-mon_count}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = [
    "${openstack_compute_secgroup_v2.secgrp_ceph.id}",
  ]
  admin_state_up     = "true"
  fixed_ip           = {
    subnet_id        = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

resource "openstack_compute_keypair_v2" "otc" {
  name       = "otc2"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.project}-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.project}-subnet"
  network_id      = "${openstack_networking_network_v2.network.id}"
  cidr            = "192.168.100.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "100.125.4.25"]
}

provider "openstack" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

resource "openstack_networking_router_v2" "router" {
  name             = "${var.project}-router"
  admin_state_up   = "true"
  #external_gateway = "${data.openstack_networking_network_v2.external_network.id}"
  external_gateway = "0a2228f2-7f8a-45f1-8e09-9039e1d09975"
}

resource "openstack_networking_router_interface_v2" "interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

resource "openstack_compute_secgroup_v2" "secgrp_jmp" {
  name        = "${var.project}-secgrp-jmp"
  description = "Jumpserver Security Group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgrp_ceph" {
  name        = "${var.project}-secgrp-ceph-osd"
  description = "CEPH-OSD stack Security Group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    self        = true
  }
}

resource "openstack_blockstorage_volume_v2" "vols" {
  count           = "${var.ceph-osd_count * var.disks-per-osd_count}"
  name = "${var.project}-${format("vol-%03d", count.index + 1)}"
  size = "${var.vol_size}"
  volume_type = "${var.vol_type}"
  availability_zone = "${var.availability_zone}"
}

resource "openstack_compute_volume_attach_v2" "vas" {
  count           = "${var.ceph-osd_count * var.disks-per-osd_count}"
  instance_id = "${element(openstack_compute_instance_v2.ceph-osds.*.id, count.index / var.disks-per-osd_count)}"
  volume_id   = "${element(openstack_blockstorage_volume_v2.vols.*.id, count.index)}"
}
