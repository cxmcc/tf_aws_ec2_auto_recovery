# tf_aws_ec2_auto_recovery

A Terraform template for EC2 Auto Recovery

This terraform module implements
- [Auto Recovery for Amazon EC2](https://aws.amazon.com/blogs/aws/new-auto-recovery-for-amazon-ec2/)
- [Route53 Healthchecks and Failover](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html)

This is useful when
- You need to have a group of EC2 instances that need static public IPs (EIP)
- The software on EC2 instances is relatively reliable and you only need to worry about EC2 system errors
- EC2 instances type is one of C3, C4, M3, R3, and T2

Alternatives
- When static IP (EIP) is not needed, ELB with auto scaling group should be considered

### Example
```HCL
module "static-ip-ec2-instances" {
  source                 = "github.com/cxmcc/tf_aws_ec2_auto_recovery"
  count                  = 2
  domain                 = "static-ip.example.com"
  route53_hosted_zone_id = "ZZZZFFFFEEEENNNN"
  ami                    = "ami-1234567"
  health_check_path      = "/route53_health_check"
  instance_type          = "m3.medium"
  name                   = "static-ip-instance"
  key_name               = "default"
  subnet_ids             = ["subnet-123456", "subnet-234567"]
  vpc_security_group_ids = ["sg-1234567"]

  user_data = <<EOF
#cloud-config
hostname: static-ip-instance
manage_etc_hosts: true
EOF
}
```
