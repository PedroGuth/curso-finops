# ============================================================
# 🔍 FinOps na AWS - Makefile
# ============================================================

REGION ?= us-east-1
SCRIPTS_DIR := scripts
TOOLS_DIR := tools
LABS_DIR := labs

.DEFAULT_GOAL := help

.PHONY: help audit audit-report check-tags migrate-gp2 cleanup-eips cleanup-snapshots \
        find-idle find-old-gen optimize calc-ri deploy-dashboard deploy-alerts \
        lab1 lab2 lab4 lab5 lab6 lab1-destroy lab2-destroy lab4-destroy lab5-destroy lab6-destroy \
        validate clean all-dry-run

help: ## 📖 Mostra todos os targets disponíveis
	@echo ""
	@echo "🔍 FinOps na AWS - Comandos Disponíveis"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# --- Auditoria ---

audit: ## 🔍 Roda auditoria completa de custos
	@bash $(SCRIPTS_DIR)/finops-audit.sh --region $(REGION) --output terminal

audit-report: ## 📝 Gera relatório de auditoria em Markdown
	@bash $(SCRIPTS_DIR)/finops-audit.sh --region $(REGION) --output markdown

# --- Scripts de Otimização ---

check-tags: ## 🏷️  Verifica compliance de tags
	@bash $(TOOLS_DIR)/tag-compliance-checker.sh

migrate-gp2: ## 💾 Migra volumes gp2→gp3 (dry-run)
	@bash $(SCRIPTS_DIR)/migrate-gp2-to-gp3.sh --dry-run --region $(REGION)

cleanup-eips: ## 🌐 Libera EIPs não associados (dry-run)
	@bash $(SCRIPTS_DIR)/cleanup-unused-eips.sh --dry-run --region $(REGION)

cleanup-snapshots: ## 📸 Remove snapshots órfãos (dry-run)
	@bash $(SCRIPTS_DIR)/cleanup-orphan-snapshots.sh --dry-run --region $(REGION)

find-idle: ## 😴 Encontra instâncias RDS ociosas
	@bash $(SCRIPTS_DIR)/find-idle-rds.sh --region $(REGION)

find-old-gen: ## 🏚️  Encontra instâncias EC2 de geração antiga
	@bash $(SCRIPTS_DIR)/find-old-gen-instances.sh --region $(REGION)

# --- Ferramentas ---

optimize: ## 🚀 Roda análise completa de otimização
	@python3 $(TOOLS_DIR)/aws-cost-optimizer.py --region $(REGION)

calc-ri: ## 🧮 Calcula economia com RIs e Savings Plans
	@python3 $(TOOLS_DIR)/reserved-instances-calculator.py --simulate t3.large:5 m5.xlarge:2

# --- Deploy ---

deploy-dashboard: ## 📊 Deploy do dashboard CloudWatch
	@aws cloudwatch put-dashboard --region $(REGION) \
		--dashboard-name FinOps-Dashboard \
		--dashboard-body file://$(TOOLS_DIR)/finops-dashboard.json
	@echo "✅ Dashboard deployed"

deploy-alerts: ## 🚨 Deploy de alertas de custo (CloudFormation)
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(TOOLS_DIR)/cost-anomaly-alerts.yaml \
		--stack-name finops-cost-alerts \
		--capabilities CAPABILITY_IAM
	@echo "✅ Alerts deployed"

# --- Labs ---

lab1: ## 🧪 Deploy Lab 1 - Config Tags
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(LABS_DIR)/lab-01-config-tags/template.yaml \
		--stack-name finops-lab-01 \
		--capabilities CAPABILITY_IAM
	@echo "✅ Lab 1 deployed"

lab2: ## 🧪 Deploy Lab 2 - Auto Scaling
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(LABS_DIR)/lab-02-auto-scaling/template.yaml \
		--stack-name finops-lab-02 \
		--capabilities CAPABILITY_IAM
	@echo "✅ Lab 2 deployed"

lab4: ## 🧪 Deploy Lab 4 - CloudFront Endpoints
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(LABS_DIR)/lab-04-cloudfront-endpoints/template.yaml \
		--stack-name finops-lab-04 \
		--capabilities CAPABILITY_IAM
	@echo "✅ Lab 4 deployed"

lab5: ## 🧪 Deploy Lab 5 - S3 Lifecycle
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(LABS_DIR)/lab-05-s3-lifecycle/template.yaml \
		--stack-name finops-lab-05 \
		--capabilities CAPABILITY_IAM
	@echo "✅ Lab 5 deployed"

lab6: ## 🧪 Deploy Lab 6 - Instance Scheduler
	@aws cloudformation deploy --region $(REGION) \
		--template-file $(LABS_DIR)/lab-06-instance-scheduler/template.yaml \
		--stack-name finops-lab-06 \
		--capabilities CAPABILITY_IAM
	@echo "✅ Lab 6 deployed"

lab1-destroy: ## 💥 Destroy Lab 1
	@aws cloudformation delete-stack --region $(REGION) --stack-name finops-lab-01
	@echo "🗑️  Lab 1 stack deletion initiated"

lab2-destroy: ## 💥 Destroy Lab 2
	@aws cloudformation delete-stack --region $(REGION) --stack-name finops-lab-02
	@echo "🗑️  Lab 2 stack deletion initiated"

lab4-destroy: ## 💥 Destroy Lab 4
	@aws cloudformation delete-stack --region $(REGION) --stack-name finops-lab-04
	@echo "🗑️  Lab 4 stack deletion initiated"

lab5-destroy: ## 💥 Destroy Lab 5
	@aws cloudformation delete-stack --region $(REGION) --stack-name finops-lab-05
	@echo "🗑️  Lab 5 stack deletion initiated"

lab6-destroy: ## 💥 Destroy Lab 6
	@aws cloudformation delete-stack --region $(REGION) --stack-name finops-lab-06
	@echo "🗑️  Lab 6 stack deletion initiated"

# --- Validação ---

validate: ## ✅ Valida todos os arquivos do repositório
	@echo "🔍 Validando JSON..."
	@find . -name '*.json' -exec python3 -m json.tool {} > /dev/null \;
	@echo "🔍 Validando YAML..."
	@find . -name '*.yaml' -o -name '*.yml' | xargs -I{} python3 -c "import yaml;yaml.safe_load(open('{}'))"
	@echo "🔍 Validando Shell scripts..."
	@find . -name '*.sh' -exec bash -n {} \;
	@echo "🔍 Validando Python..."
	@find . -name '*.py' -exec python3 -m py_compile {} \;
	@echo "🔍 Validando SQL (syntax check)..."
	@find . -name '*.sql' -exec test -s {} \;
	@echo "✅ Todas as validações passaram!"

# --- Limpeza ---

clean: ## 🧹 Remove arquivos temporários
	@rm -rf .terraform .terraform.lock.hcl
	@rm -f terraform/*.tfstate terraform/*.tfstate.backup
	@rm -f finops-audit-report.md
	@rm -f *.tmp *.log
	@echo "🧹 Limpeza concluída"

# --- Batch ---

all-dry-run: ## 🏃 Roda todos os scripts em modo dry-run
	@echo "🏃 Executando todos os scripts em dry-run..."
	@echo ""
	@echo "━━━ migrate-gp2 ━━━"
	@-bash $(SCRIPTS_DIR)/migrate-gp2-to-gp3.sh --dry-run --region $(REGION)
	@echo ""
	@echo "━━━ cleanup-eips ━━━"
	@-bash $(SCRIPTS_DIR)/cleanup-unused-eips.sh --dry-run --region $(REGION)
	@echo ""
	@echo "━━━ cleanup-snapshots ━━━"
	@-bash $(SCRIPTS_DIR)/cleanup-orphan-snapshots.sh --dry-run --region $(REGION)
	@echo ""
	@echo "✅ Dry-run completo!"
