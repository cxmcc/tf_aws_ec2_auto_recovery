resource "aws_eip" "eip" {
  count = "${var.count}"
  vpc   = true
}

resource "aws_instance" "instance" {
  count                  = "${var.count}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  key_name               = "${var.key_name}"
  user_data              = "${var.user_data}"

  ephemeral_block_device {
    device_name  = "/dev/sdb"
    no_device    = "true"
    virtual_name = "ephemeral0"
  }

  ephemeral_block_device {
    device_name  = "/dev/sdc"
    no_device    = "true"
    virtual_name = "ephemeral1"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_eip_association" "eip_association" {
  count         = "${var.count}"
  instance_id   = "${element(aws_instance.instance.*.id, count.index)}"
  allocation_id = "${element(aws_eip.eip.*.id, count.index)}"
}

resource "aws_cloudwatch_metric_alarm" "auto_recovery_alarm" {
  count               = "${var.count}"
  alarm_name          = "EC2AutoRecover-${element(aws_instance.instance.*.id, count.index)}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"

  dimensions = {
    InstanceId = "${element(aws_instance.instance.*.id, count.index)}"
  }

  alarm_actions = ["arn:aws:automate:${substr(element(aws_instance.instance.*.availability_zone, count.index), 0, length(element(aws_instance.instance.*.availability_zone, count.index)) - 1)}:ec2:recover"]

  threshold         = "1"
  alarm_description = "Auto recover the EC2 instance if Status Check fails."
}

resource "aws_route53_health_check" "route53_health_check" {
  count             = "${var.count}"
  ip_address        = "${element(aws_eip.eip.*.public_ip, count.index)}"
  port              = 80
  type              = "HTTP"
  resource_path     = "${var.health_check_path}"
  failure_threshold = "5"
  request_interval  = "10"

  tags = {
    Name = "${var.name}-${element(aws_instance.instance.*.id, count.index)}"
  }
}

resource "aws_route53_record" "route53_record" {
  count   = "${var.count}"
  zone_id = "${var.route53_hosted_zone_id}"
  name    = "${var.domain}"
  type    = "A"
  ttl     = "60"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier  = "${element(aws_instance.instance.*.id, count.index)}"
  records         = ["${element(aws_eip.eip.*.public_ip, count.index)}"]
  health_check_id = "${element(aws_route53_health_check.route53_health_check.*.id, count.index)}"
}
