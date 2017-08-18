output "eips" {
  value = "${aws_eip.eip..*.public_ip}"
}

output "instance_ids" {
  value = "${aws_instance.instance.*.id}"
}
