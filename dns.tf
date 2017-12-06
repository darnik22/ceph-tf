resource "openstack_dns_zone_v2" "dnszone" {
  name  = "${var.dnszone}."
  email = "${var.email}"
#  ttl   = 60
#  type  = "PRIMARY"
}

resource "openstack_dns_recordset_v2" "recordset" {
  count   = "${var.provider_count}"
  zone_id = "${openstack_dns_zone_v2.dnszone.id}"
  name    = "${element(openstack_compute_instance_v2.providers.*.name, count.index)}.${var.dnszone}."
#  ttl     = 3000
  type    = "A"
  records = ["${element(openstack_networking_floatingip_v2.providers.*.address, count.index)}"] #"${openstack_networking_floatingip_v2.providers.*.address}"]
}
