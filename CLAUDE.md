# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Layout & commands

Single Terraform root module at `multi-az-ha-lab/`. The repo-root `Makefile` uses `terraform -chdir=multi-az-ha-lab`, so `make` targets work from repo root; direct `terraform` invocations must `cd multi-az-ha-lab/` first. CI (`.github/workflows/terraform-validate.yml`) runs `fmt -check -recursive`, `init -backend=false`, `validate` on Terraform 1.7.0 with `working-directory: ./multi-az-ha-lab`. A separate Infracost PR workflow needs `INFRACOST_API_KEY`.

## Architecture

Default region `ap-south-1` (override via `var.region`). Split across `providers.tf`, `variables.tf`, `vpc.tf`, `security.tf`, `iam.tf`, `alb.tf`, `compute.tf`, `outputs.tf`.

- VPC CIDR and subnet CIDRs come from `variables.tf`. AZs are picked dynamically via `data.aws_availability_zones`; AZ count = length of the subnet CIDR lists.
- IGW + NAT Gateway(s). `var.single_nat_gateway` (default `true`) toggles between one shared NAT and per-AZ NATs.
- ALB (public subnets) → target group :80 health `/` → Launch Template (latest Ubuntu 22.04 via `data.aws_ami`, `var.instance_type`, nginx user_data) → ASG across private subnets, `health_check_type = "ELB"`.
- IAM instance profile with `AmazonSSMManagedInstanceCore` — SSM is the intended access path, no SSH/bastion.
- `aws_security_group.alb` :80 from `0.0.0.0/0`; `aws_security_group.app` :80 only from the ALB SG.

## Gotchas

- **Remote backend**: S3 bucket `tfstate-ha-lab-334044477795` + DynamoDB lock table `tfstate-ha-lab-locks` in `ap-south-1`. Bootstrap resources were created out-of-band via AWS CLI (see README "Remote State" section). Any clone must change the bucket name in `providers.tf` to match their account before `terraform init`.
- NAT + ALB cost ~$50/mo idle in `ap-south-1`. Run `terraform destroy` when done.
