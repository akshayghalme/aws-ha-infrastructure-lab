# 🚀 AWS High-Availability Infrastructure Lab

## Production-Style Multi-AZ Architecture using Terraform

---

## 📌 Project Overview

This repository demonstrates the design and implementation of a **production-grade, highly available AWS architecture** using Infrastructure as Code (Terraform).

The goal of this project is not just provisioning resources — but engineering a **resilient, secure, and scalable infrastructure** aligned with real-world DevOps and Solution Architecture practices.

### This lab simulates:

- Multi-AZ deployment  
- Auto Scaling & Load Balancing  
- Private networking architecture  
- Failure handling scenarios  
- Cost optimization decisions  
- Infrastructure troubleshooting  

---

## 🏗 Architecture Design

### Core Components

- Custom VPC (10.0.0.0/16)
- 2 Public Subnets (Multi-AZ)
- 2 Private Subnets (Multi-AZ)
- Internet Gateway
- NAT Gateway (Private subnet outbound access)
- Application Load Balancer (Internet-facing)
- Auto Scaling Group (Multi-AZ)
- Launch Template (Apache bootstrap via user data)
- IAM Role (No access keys model)
- Security Groups (Least privilege)
- Target Group with health checks

---

## 🔄 Traffic Flow

Internet
↓
Application Load Balancer (Public Subnets)
↓
Target Group
↓
Auto Scaling Group Instances (Private Subnets)
↓
Outbound traffic via NAT Gateway


---

## 🔐 Security Design

This infrastructure follows **security-first principles**:

- EC2 instances deployed in private subnets
- No direct public SSH access
- IAM Roles used instead of static credentials
- Security groups restricted by function
- Load balancer handles public traffic exposure
- Health checks enforce instance reliability

---

## ⚙️ Terraform Implementation

Infrastructure is provisioned entirely using **Terraform**.

### Structure

terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf


### Core Concepts Used

- Resource dependencies
- Launch Templates
- Auto Scaling Groups
- ALB target group attachments
- Multi-AZ subnet distribution
- Health check configuration
- IAM instance profile association

---

## 🧪 Failure Simulation & Troubleshooting

This lab intentionally included failure scenarios to simulate **production-grade troubleshooting**:

- ❌ NAT route misconfiguration
- ❌ NACL outbound rule blocking internet access
- ❌ ALB health check failures
- ❌ Dependency violations during resource destroy
- ❌ Manual resource drift vs Terraform state

Each issue was diagnosed using:

- Linux networking commands (`ip route`, `curl`, `tracepath`)
- AWS Console inspection
- Terraform plan & state analysis
- Security group & NACL rule auditing

---

## 💰 Cost Optimization Decisions

This project evaluates cost trade-offs including:

- `t3.micro` instance sizing
- Single NAT vs Multi-NAT architecture
- On-demand vs Reserved pricing strategy
- Resource cleanup via `terraform destroy`
- Minimizing idle infrastructure

---

## 📊 Key Learning Outcomes

- Designing resilient multi-AZ infrastructure
- Understanding AWS networking deeply (Route Tables, NACLs, SGs)
- Debugging real-world connectivity issues
- Managing Terraform state responsibly
- Avoiding manual drift in IaC environments
- Thinking in terms of failure domains

---

## 🛠 Terraform Commands Used

```bash
terraform init        # Initialize provider & modules
terraform fmt         # Format code
terraform validate    # Validate configuration
terraform plan        # Preview infrastructure changes
terraform apply       # Provision infrastructure
terraform destroy     # Tear down infrastructure
terraform state list  # Inspect state
terraform state rm    # Remove orphaned resources

📈 Current Capabilities

✔ Multi-AZ Application Deployment

✔ Load Balanced Infrastructure

✔ Auto Scaling Enabled

✔ Health Check Monitoring

✔ Private Subnet Architecture

✔ IAM-based Access Model

🚀 Future Enhancements

HTTPS with ACM certificate

WAF integration

Blue-Green deployment strategy

CloudWatch dashboards & alarms

RDS Multi-AZ database layer

CI/CD pipeline integration (GitHub Actions / Jenkins)

EKS-based containerized architecture

📎 Why This Project Matters

This project reflects:

Infrastructure engineering mindset

Production-aware design decisions

Hands-on troubleshooting capability

Clean Infrastructure-as-Code practices

Multi-layer AWS networking understanding

It is built as a portfolio-level demonstration of real-world DevOps engineering skills.

👨‍💻 Author

Akshay Ghalme
DevOps Engineer | AWS | Terraform | High Availability Architectures
