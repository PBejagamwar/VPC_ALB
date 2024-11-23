output "alb_dns_name" {
    description = "ALB DNS name"
    value = aws_lb.app_alb.dns_name
  
}


output "ec2_public_ips" {
  value = data.aws_instances.asg_instances.public_ips
}
