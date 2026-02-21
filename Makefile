.PHONY: init validate plan apply destroy fmt security cost

init:
	terraform init

validate:
	terraform validate && terraform fmt -check

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy -auto-approve

fmt:
	terraform fmt -recursive

security:
	tfsec .

cost:
	infracost breakdown --path=.
