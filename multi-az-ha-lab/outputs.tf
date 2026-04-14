output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "HTTP URL to reach the application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (one per AZ)"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (one per AZ)"
  value       = aws_subnet.private[*].id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group running the app"
  value       = aws_autoscaling_group.app.name
}
