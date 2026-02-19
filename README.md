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

## 🏗 Architecture Design – Core Components

- Custom VPC (10.0.0.0/16)
- 2 Public Subnets (Multi-AZ)
- 2 Private Subnets (Multi-AZ)
- Internet Gateway
- NAT Gateway
- Application Load Balancer (ALB)
- Launch Template
- Auto Scaling Group
- IAM Role-based access (No SSH keys)
- CloudWatch Monitoring

---

## 🔐 Security Design

- Private EC2 instances (no public IP)
- Security group segmentation
- Least privilege IAM policies
- SSM-based access (no direct SSH)

---

## ⚙️ Failure Simulation

- Instance termination testing
- Health check validation
- NAT removal impact
- Target group recovery

---

## 💰 Cost Optimization Strategy

- Instance type selection (t3.micro)
- gp3 storage
- NAT cost consideration
- On-demand vs reserved analysis

---

## 🚀 Future Enhancements

- WAF integration
- Blue/Green deployment
- CI/CD pipeline integration
- EKS version of architecture

---

## 🧠 Key Learning Outcomes

- Real-world multi-AZ architecture design
- Terraform modular thinking
- Debugging AWS networking issues
- Understanding ALB + ASG integration
- Production mindset over tutorial mindset
