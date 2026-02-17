
# aws-ha-infrastructure-lab
High-Availability AWS Infrastructure Lab with Terraform, failure simulation, and cost optimization analysis.

# AWS High-Availability Infrastructure Lab

## 📌 Overview

This repository demonstrates the design and provisioning of a secure, multi-AZ AWS infrastructure using Terraform.

The goal of this lab is to simulate production-grade architecture, failure testing, and cost optimization strategies.

---

## 🏗 Architecture Components

- Custom VPC with public and private subnets
- Internet Gateway
- NAT Gateway
- EC2 instances
- Application Load Balancer
- RDS deployed in private subnet
- IAM role-based access (no access keys)
- CloudWatch monitoring

---

## 🔐 Security Design

- Private database deployment (no public exposure)
- Least privilege IAM policies
- Restricted security groups
- No direct SSH access (SSM preferred)

---

## ⚠ Failure Simulation

Tested scenarios:

- EC2 instance termination
- Security group misconfiguration
- Database load spike
- NAT removal impact

Recovery steps documented in `failure-scenarios.md`.

---

## 💰 Cost Optimization

- Instance type evaluation
- Storage type comparison (gp2 vs gp3)
- On-Demand vs Reserved pricing considerations
- NAT vs VPC endpoint trade-offs

Detailed analysis in `cost-analysis.md`.

---

## 🚀 Future Enhancements

- Auto Scaling Group
- WAF integration
- Blue-Green deployment strategy
- EKS version of architecture
