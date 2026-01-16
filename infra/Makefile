.PHONY: help init plan apply destroy fmt validate clean output state logs k8s-info

help:
	@echo "Terraform + Kubernetes Commands for Library App"
	@echo "==============================================="
	@echo ""
	@echo "Core Terraform:"
	@echo "  make init          - Initialize Terraform working directory"
	@echo "  make validate      - Validate Terraform configuration"
	@echo "  make fmt           - Format Terraform files"
	@echo "  make plan          - Plan infrastructure changes"
	@echo "  make apply         - Apply infrastructure changes"
	@echo "  make destroy       - Destroy all infrastructure"
	@echo "  make clean         - Clean Terraform files and state"
	@echo ""
	@echo "Information:"
	@echo "  make output        - Show Terraform outputs"
	@echo "  make state         - Show Terraform state"
	@echo "  make logs          - Show cluster and pod logs"
	@echo "  make k8s-info      - Show Kubernetes cluster info"
	@echo ""

init:
	@echo "🔧 Initializing Terraform..."
	terraform init

validate:
	@echo "✓ Validating Terraform configuration..."
	terraform validate

fmt:
	@echo "🎨 Formatting Terraform files..."
	terraform fmt -recursive

plan:
	@echo "📋 Planning infrastructure changes..."
	terraform plan -var-file=env.tfvars -out=app.plan

apply:
	@echo "🚀 Applying infrastructure changes..."
	terraform apply -var-file=env.tfvars

apply-plan:
	@echo "🚀 Applying from saved plan..."
	terraform apply app.plan

destroy:
	@echo "💥 Destroying infrastructure..."
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy -var-file=env.tfvars; \
	else \
		echo "Destroy cancelled."; \
	fi

clean:
	@echo "🧹 Cleaning Terraform files..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f app.plan
	rm -f terraform.tfstate*
	@echo "✓ Clean complete"

output:
	@echo "📊 Terraform Outputs:"
	terraform output

state:
	@echo "📁 Terraform State:"
	terraform show

logs:
	@echo "📋 Pod Logs:"
	kubectl logs -n library-app -l app=postgres --tail=50 || echo "PostgreSQL pod not ready"
	kubectl logs -n library-app -l app=django --tail=50 || echo "Django pod not ready"

k8s-info:
	@echo "🔍 Kubernetes Cluster Info:"
	kubectl cluster-info || echo "Cluster not accessible"
	@echo ""
	@echo "📦 Namespaces:"
	kubectl get ns || echo "Cannot get namespaces"
	@echo ""
	@echo "🏃 Pods in library-app namespace:"
	kubectl get pods -n library-app || echo "Namespace not ready"
	@echo ""
	@echo "🔌 Services in library-app namespace:"
	kubectl get svc -n library-app || echo "Services not ready"
