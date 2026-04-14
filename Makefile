.PHONY: init validate plan apply destroy fmt security cost

TF_DIR := multi-az-ha-lab

init:
	terraform -chdir=$(TF_DIR) init

validate:
	terraform -chdir=$(TF_DIR) validate && terraform -chdir=$(TF_DIR) fmt -check

plan:
	terraform -chdir=$(TF_DIR) plan -out=tfplan

apply:
	terraform -chdir=$(TF_DIR) apply tfplan

destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve

fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

security:
	tfsec $(TF_DIR)

cost:
	infracost breakdown --path=$(TF_DIR)
