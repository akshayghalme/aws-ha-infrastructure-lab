![Terraform CI](https://github.com/akshayghalme/aws-ha-infrastructure-lab/actions/workflows/terraform-validate.yml/badge.svg)

# AWS High-Availability Infrastructure Lab

Production-Grade Multi-AZ Architecture using Terraform (Infrastructure as Code)

<img width="2880" height="2980" alt="aws-ha-architecture" src="https://github.com/user-attachments/assets/c7f9ba61-83ad-4581-b0f1-c6c2c66394de" />


---

## Overview

This project demonstrates the design and implementation of a highly available, production-style AWS infrastructure using Terraform.

The objective is not only to provision cloud resources, but to design a resilient, secure, and scalable architecture aligned with real-world DevOps, Cloud Engineering, and Solution Architecture practices.

This lab simulates enterprise-grade infrastructure patterns including multi-AZ deployment, auto scaling, secure networking, and failure recovery scenarios.

---

## Architecture Summary

### Core AWS Services Used

- Amazon VPC (10.0.0.0/16)
- Public and Private Subnets (Multi-AZ)
- Internet Gateway
- NAT Gateway
- Application Load Balancer (ALB)
- Target Groups with Health Checks
- Auto Scaling Group (ASG)
- Launch Template
- IAM Roles and Instance Profiles
- Security Groups
- Network ACLs

---

## High-Level Traffic Flow

Internet  
→ Application Load Balancer (Public Subnets)  
→ Target Group  
→ Auto Scaling Group EC2 Instances (Private Subnets)  
→ Outbound Internet via NAT Gateway  

---

## Security Architecture

This infrastructure follows security-first principles:

- EC2 instances deployed in private subnets
- No direct public SSH access
- IAM Roles used instead of access keys
- Least privilege security group rules
- ALB as the only public entry point
- Health checks enforcing instance reliability
- Controlled outbound access via NAT Gateway

---

## Terraform Implementation

Infrastructure is provisioned entirely using Terraform.

### Structure

terraform/
├── main.tf  
├── providers.tf  
├── variables.tf  
├── outputs.tf  

### Key Terraform Concepts Applied

- Infrastructure as Code (IaC)
- Resource dependency management
- Launch Templates with user data bootstrap
- Auto Scaling Group lifecycle management
- ALB target group attachments
- Multi-AZ subnet distribution
- IAM instance profile association
- Health check configuration
- State management and drift handling

---

## Failure Simulation & Troubleshooting

This lab intentionally includes failure scenarios to simulate real production debugging:

- NAT route misconfiguration
- NACL outbound rule blocking internet access
- ALB health check failures
- Security group dependency violations
- Terraform destroy dependency conflicts
- Manual resource drift vs Terraform state

Issues were diagnosed using:

- Linux networking commands (ip route, curl, tracepath)
- Systemctl service validation
- Terraform plan and state inspection
- AWS Console verification
- Route table and NACL auditing

---

## Cost Optimization Considerations

- Instance sizing strategy (t3.micro evaluation)
- Single NAT vs Multi-NAT architecture trade-offs
- Resource lifecycle management using terraform destroy
- Minimizing idle infrastructure
- Understanding AWS billing impact of networking components

---

## DevOps & Cloud Skills Demonstrated

- AWS Networking (VPC, Subnets, Route Tables, NACLs, SGs)
- High Availability Design (Multi-AZ)
- Auto Scaling & Load Balancing
- Infrastructure as Code (Terraform)
- IAM Role-Based Access Control
- Linux Server Administration
- Production Troubleshooting
- Infrastructure Debugging
- Failure Domain Analysis
- Cost-Aware Architecture Design

---

## Terraform Commands Used

terraform init  
terraform fmt  
terraform validate  
terraform plan  
terraform apply  
terraform destroy  
terraform state list  
terraform state rm  

---

## Current Capabilities

- Multi-AZ Application Deployment
- Load Balanced Infrastructure
- Auto Scaling Enabled
- Health Check Monitoring
- Private Subnet Architecture
- IAM-Based Access Model

---

## Future Enhancements

- HTTPS with ACM Certificate
- AWS WAF Integration
- Blue-Green Deployment Strategy
- CloudWatch Dashboards & Alarms
- RDS Multi-AZ Database Layer
- CI/CD Integration (GitHub Actions / Jenkins)
- EKS-Based Containerized Architecture

---

## Why This Project Matters

This project reflects:

- Infrastructure engineering mindset
- Production-aware design decisions
- Hands-on troubleshooting capability
- Clean Infrastructure-as-Code practices
- Multi-layer AWS networking understanding

It serves as a portfolio-level demonstration of practical DevOps and cloud architecture skills.

---

## Author

Akshay Ghalme  
DevOps Engineer | AWS | Terraform | High Availability Architectures
