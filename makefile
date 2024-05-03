.PHONY: init plan apply destroy clean quick-apply help

TERRAFORM = terraform/
ENV ?= dev
PLAN = plan.tfplan

help:
	@echo "Makefile commands:"
	@echo "check-fmt - Check Terraform formatting"
	@echo "init - Initialize Terraform"
	@echo "plan - Generate a Terraform plan"
	@echo "apply - Apply the Terraform plan"
	@echo "destroy - Destroy the Terraform infrastructure"
	@echo "clean - Clean up Terraform files"
	@echo "quick-apply - Quickly initialize, plan, and apply Terraform"
	@echo ""
	@echo "Variables:"
	@echo "TERRAFORM - Path to the Terraform code. Default: /terraform"
	@echo "ENV - The environment to use. Default: dev"
	@echo "PLAN - The name of the Terraform plan file. Default: plan.tfplan"
	@echo "To set an environment variable for a single command, prefix the command with the variable assignment."
	@echo ""For example, to set the ENV variable for the 'apply' command, run:"
	@echo "ENV=prod make apply"

check-fmt:
	cd $(TERRAFORM) && terraform fmt -recursive -check

init:
	cd $(TERRAFORM) && terraform init -backend-config=backend/$(ENV).hcl

plan:
	cd $(TERRAFORM) && terraform plan -out=$(PLAN) -var-file=tfvars/$(ENV).tfvars

apply:
	cd $(TERRAFORM) && terraform apply $(PLAN)

destroy:
	cd $(TERRAFORM) && terraform destroy -var-file=tfvars/$(ENV).tfvars

force-destroy:
	cd $(TERRAFORM) && terraform destroy -var-file=tfvars/$(ENV).tfvars -auto-approve

clean:
	cd $(TERRAFORM) && rm -rf .terraform* $(PLAN)