# Changelog

## [1.1.0] - 2026-02-21
### Added
- GitHub Actions CI/CD pipeline (Terraform validate + tfsec + Checkov)
- Infracost workflow for PR cost estimation
- Architecture diagram in README
- Makefile for simplified commands
- terraform.tfvars.example for easy onboarding

## [1.0.0] - 2026-02-18
### Added
- Initial release
- Multi-AZ VPC with public and private subnets
- Application Load Balancer
- Auto Scaling Group with Launch Template
- NAT Gateway per AZ
- IAM Roles and Instance Profiles
- Security Groups and NACLs
