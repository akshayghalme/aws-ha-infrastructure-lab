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

- Amazon VPC (10.0.0.0/16) with public/private subnets across multiple AZs
- Internet Gateway + NAT Gateway(s) (single or per-AZ, toggleable)
- Application Load Balancer with target groups and health checks
- Auto Scaling Group with Launch Template, rolling instance refresh
- EC2 (Ubuntu 22.04 via data source, nginx bootstrap + node_exporter)
- IAM roles / instance profiles (SSM-managed, no SSH)
- Security Groups (ALB → app → monitoring, least privilege)
- Monitoring EC2 running Prometheus + Grafana (Docker)
- S3 + DynamoDB for remote Terraform state and locking

---

## High-Level Traffic Flow

**App request path**
Internet → ALB (public subnets) → Target Group → ASG EC2 in private subnets → Outbound egress via NAT Gateway.

**Observability path**
Prometheus (monitoring EC2, public subnet) uses the AWS EC2 service discovery API to find app instances tagged `Project=ha-lab`, then scrapes `node_exporter` on port 9100 across the VPC's private subnets. Grafana queries Prometheus locally and serves dashboards on port 3000 to the `admin_cidr` allowlist.

---

## Security Architecture

This infrastructure follows security-first principles:

- App EC2 instances deployed in private subnets with no public IPs
- No SSH at all — access is via AWS Systems Manager Session Manager
- IAM instance profiles instead of long-lived access keys
- Least-privilege security groups: ALB → app on 80, monitoring → app on 9100
- ALB is the only public entry point for application traffic
- IMDSv2 required on the monitoring instance (`http_tokens = "required"`)
- Grafana/Prometheus UIs gated by `var.admin_cidr` (lock to your IP in real use)
- Remote state bucket is versioned, encrypted at rest, and public-access-blocked

---

## Terraform Implementation

Infrastructure is provisioned entirely using Terraform.

### Structure

multi-az-ha-lab/
├── providers.tf    # Terraform + AWS provider, S3 backend, AMI/AZ data sources
├── variables.tf    # All tunables (region, CIDRs, instance type, ASG sizing, NAT toggle, admin_cidr)
├── vpc.tf          # VPC, subnets, IGW, NAT, route tables, CIDR sanity check
├── security.tf     # Security groups (ALB, app, monitoring)
├── iam.tf          # EC2 IAM role + SSM instance profile
├── alb.tf          # ALB, target group, listener
├── compute.tf      # Launch template + ASG (instance refresh, health check grace)
├── monitoring.tf   # Prometheus + Grafana EC2, monitoring IAM + SG
├── templates/      # templatefile() sources for prometheus.yml and user_data
└── outputs.tf      # alb_url, grafana_url, prometheus_url, ids

### Key Terraform Concepts Applied

- Remote state backend (S3 + DynamoDB lock) with versioning and encryption
- `data` sources for dynamic AZ discovery and latest Ubuntu AMI
- `templatefile()` for injecting variables into Prometheus config and user_data
- Launch template with `create_before_destroy` + ASG `instance_refresh` for zero-downtime rollouts
- `health_check_grace_period` tuned so ELB doesn't kill instances mid-bootstrap
- `count`-driven subnet/NAT resources with a `var.single_nat_gateway` HA/cost toggle
- `default_tags` on the provider plus explicit tags where `tag_specifications` are required
- Top-level `check` block validating cross-variable invariants
- `name_prefix` on ASG so replace-forcing changes don't collide

---

## Cost Notes

Idle cost in `ap-south-1` is roughly:

- NAT Gateway: ~$32/mo (single-NAT mode; doubles with `single_nat_gateway = false`)
- Application Load Balancer: ~$16/mo
- Monitoring EC2 (`t3.small`) + 20 GiB gp3: ~$15/mo
- App EC2 instances (`t3.micro` × 2): ~$15/mo
- S3 + DynamoDB state backend: pennies

**~$80/mo** all-in if left running. Destroy with `terraform destroy` between demos.

---

## DevOps & Cloud Skills Demonstrated

- AWS networking: VPC, subnets, route tables, security groups, NAT/IGW topology
- High-availability design across multiple AZs with a toggleable NAT HA/cost trade-off
- Auto Scaling + Load Balancing with zero-downtime rolling updates (instance refresh)
- Terraform: modules-less but file-split, remote state, data sources, `templatefile()`, `check` blocks
- IAM role-based access, SSM-only host access (no SSH, no bastion)
- Observability: Prometheus EC2 service discovery, Grafana dashboards, node_exporter
- CI: `fmt -check` + `validate` on every push via GitHub Actions
- Cost-aware architecture (documented idle cost and knobs)

---

## Current Capabilities

- Multi-AZ application deployment behind an Application Load Balancer
- Auto Scaling Group with rolling instance refresh on launch template changes
- Private-subnet EC2, SSM-only access, no SSH
- Prometheus + Grafana observability with EC2 service discovery
- Pre-built Node Exporter dashboard (Grafana dashboard ID `1860`) for live CPU / memory / network / disk per instance
- Remote Terraform state with locking, versioning, and encryption
- CI runs `terraform fmt -check` + `validate` on every push

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

# URLs (also printed at the end of apply)
terraform output alb_url
terraform output grafana_url
terraform output prometheus_url

# tear down (NAT + ALB + monitoring EC2 ~$55/mo idle)
terraform destroy
```

All knobs live in `variables.tf` — override via `-var` or a `terraform.tfvars` file. Set `single_nat_gateway = false` for true per-AZ HA at ~2× NAT cost. Set `admin_cidr` to your own IP to lock down the Grafana/Prometheus UIs.

---

## Observability

The monitoring EC2 boots Docker, writes a templated `prometheus.yml`, and runs Prometheus + Grafana as containers. Prometheus uses the AWS `ec2_sd_configs` service discovery to find every instance tagged `Project=ha-lab` that is `running`, then scrapes `node_exporter` on port 9100 (installed on app instances via `apt-get install prometheus-node-exporter` in user_data).

**After `terraform apply`:**
1. Open `terraform output grafana_url` (default login `admin` / `admin`).
2. Add a Prometheus data source — URL is the Prometheus EC2 public IP on port 9090 (Grafana runs in a bridged container, so `localhost` won't reach host-networked Prometheus).
3. Import dashboard ID `1860` (Node Exporter Full) — the `instance` dropdown switches between ASG hosts.

Prometheus targets page: `${prometheus_url}/targets` — expect `node` job at 2/2 UP once the ASG has cycled in instances with `node_exporter`.

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
