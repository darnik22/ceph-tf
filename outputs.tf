output "ceph-mgt public address" {
  value = "${openstack_networking_floatingip_v2.ceph-mgt.address}"
}

output "ceph-mon address" {
  value = "${openstack_compute_instance_v2.ceph-mons.*.access_ip_v4}"
}

output "Final message" {
  value = "Congratulations! Your Ceph cluster, oneprovider and oneclient have been successfully setup.\nUse the above mgt address to login to your cluster.\nThe logs of onedatify including onepanel credentials are stored in ubuntu@${var.project}-op-01:onedatify.stdout.\nGood luck!"
}

# output "ceph-osd address" {
#   value = "${openstack_compute_instance_v2.ceph-osds.*.access_ip_v4}"
# }

# output "ceph-osd names" {
#   value = "${openstack_compute_instance_v2.ceph-osds.*.name}"
# }


