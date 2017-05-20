output "elb_name" {
  value = "${aws_elb.main.name}"
}

output "elb_id" {
  value = "${aws_elb.main.id}"
}

output "elb_dns_name" {
  value = "${aws_elb.main.dns_name}"
}

output "elb_zone_id" {
  value = "${aws_elb.main.zone_id}"
}
