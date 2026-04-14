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

multi-az-ha-lab/
├── providers.tf   # Terraform + AWS provider, AMI/AZ data sources
├── variables.tf   # All tunables (region, CIDRs, instance type, ASG sizing)
├── vpc.tf         # VPC, subnets, IGW, NAT, route tables
├── security.tf    # Security groups
├── iam.tf         # EC2 IAM role + SSM instance profile
├── alb.tf         # ALB, target group, listener
├── compute.tf     # Launch template + ASG
└── outputs.tf     # ALB URL, VPC/subnet IDs

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

## Remote State

State lives in an S3 backend with DynamoDB locking — no `terraform.tfstate` in git, and concurrent applies are blocked safely.

Bootstrap (one-time per account) — creates a versioned, encrypted, public-access-blocked bucket and a pay-per-request lock table:

```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
BUCKET="tfstate-ha-lab-${ACCOUNT}"
aws s3api create-bucket --bucket "$BUCKET" --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws dynamodb create-table --table-name tfstate-ha-lab-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region ap-south-1
```

Then update the `bucket` name in `providers.tf` to match your account and run `terraform init`.

---

## Usage

```bash
cd multi-az-ha-lab
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# reach the app
terraform output alb_url

# tear down (NAT + ALB cost ~$50/mo idle)
terraform destroy
```

All knobs live in `variables.tf` — override via `-var` or a `terraform.tfvars` file. Set `single_nat_gateway = false` for true per-AZ HA at ~2× NAT cost.

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
