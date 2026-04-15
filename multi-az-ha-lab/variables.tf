variable "project" {
  description = "Project name used as a prefix for all resource names and tags"
  type        = string
  default     = "ha-lab"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ. Must have the same length as private_subnet_cidrs."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ. Must have the same length as public_subnet_cidrs."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for ASG launch template"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "admin_cidr" {
  description = "CIDR allowed to reach Grafana/Prometheus on the monitoring instance. Default 0.0.0.0/0 for lab; tighten to your IP in real use."
  type        = string
  default     = "0.0.0.0/0"
}

variable "grafana_admin_password" {
  description = "Initial admin password for Grafana"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (cheap) vs one per AZ (HA). Defaults to single for lab cost."
  type        = bool
  default     = true
}
