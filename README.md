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
