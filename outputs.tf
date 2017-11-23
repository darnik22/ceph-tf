output "ceph-mgt address" {
  value = "${openstack_networking_floatingip_v2.ceph-mgt.address}"
}

output "ceph-osd address" {
  value = "${openstack_compute_instance_v2.ceph-osds.*.access_ip_v4}"
}

output "boza" {
  value = "${openstack_compute_instance_v2.ceph-osds.*.name}"
}

output "port" {
  value = "${openstack_compute_instance_v2.ceph-mgt.port}"
}

output "boza2" {
  value = "${openstack_compute_instance_v2.ceph-osds.*.name}"
}

output "ceph-mgt address2" {
  value = "${openstack_networking_floatingip_v2.ceph-mgt.address}"
}

