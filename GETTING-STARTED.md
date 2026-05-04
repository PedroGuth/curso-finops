# 🚀 Getting Started — FinOps na AWS

Guia rápido para quem acabou de clonar o repositório e quer começar a economizar.

---

## Pré-requisitos

| Ferramenta | Versão mínima | Instalação (macOS) |
|------------|---------------|-------------------|
| AWS CLI | v2 | `brew install awscli` |
| Python 3 | 3.9+ | `brew install python@3` |
| jq | 1.6+ | `brew install jq` |
| Terraform | 1.5+ | `brew install terraform` |
| boto3 | latest | `pip3 install boto3` |
| tabulate | latest | `pip3 install tabulate` |

Instalação rápida de todas as dependências Python:

```bash
pip3 install boto3 tabulate
```

---

## Configuração da AWS CLI

```bash
aws configure
```

Você vai precisar informar:

```
AWS Access Key ID: <sua-access-key>
AWS Secret Access Key: <sua-secret-key>
Default region name: us-east-1
Default output format: json
```

> 💡 **Dica**: Use `us-east-1` como região padrão — é onde ficam os dados de billing e Cost Explorer.

Valide a configuração:

```bash
aws sts get-caller-identity
```

---

## ⚡ Primeiros 5 Minutos

Após configurar a AWS CLI, rode estes 3 comandos para ter uma visão imediata da sua conta:

### 1. Auditoria completa de custos

```bash
make audit
```

Analisa EC2, EBS, EIP, RDS e S3 — identifica desperdícios e oportunidades de economia.

### 2. Simular economia com Reserved Instances / Savings Plans

```bash
make calc-ri --simulate
```

Calcula quanto você economizaria comprando RIs ou Savings Plans com base no seu uso atual.

### 3. Ver tudo que pode ser otimizado (modo seguro)

```bash
make all-dry-run
```

Executa todas as otimizações em modo dry-run (sem alterar nada) para você ver o que seria feito.

---

## 🗺️ Mapa do Repositório

```
.
├── 📋 CHEATSHEET.md          ← Referência rápida (comece aqui!)
├── ❓ FAQ.md                  ← Dúvidas frequentes
├── 📖 GLOSSARIO.md           ← Termos FinOps/AWS
├── 🔀 DECISOES.md            ← Diagramas de decisão
├── 🎓 CERTIFICACOES.md       ← Guia de certificações
│
├── 🧪 labs/                   ← 6 laboratórios práticos guiados
│   ├── lab-01-config-tags/
│   ├── lab-02-auto-scaling/
│   ├── lab-03-cloudwatch-rightsizing/
│   ├── lab-04-cloudfront-endpoints/
│   ├── lab-05-s3-lifecycle/
│   └── lab-06-instance-scheduler/
│
├── 🛠️ tools/                  ← Ferramentas de análise (Python, Bash)
├── 🔧 scripts/                ← Automações prontas para usar
├── ⚡ lambda/                  ← Funções Lambda para automação
├── 🔒 policies/               ← IAM Policies e SCPs
├── 📊 queries/                ← Queries Athena para CUR
├── 🏗️ terraform/              ← Módulos Terraform reutilizáveis
├── ✅ checklists/             ← Well-Architected Checklist
├── 📝 templates/              ← Templates de relatórios
└── 🚨 runbooks/               ← Procedimentos para incidentes de custo
```

**Por onde começar?**
- Quer uma visão geral rápida? → `CHEATSHEET.md`
- Quer praticar? → `labs/`
- Quer automatizar agora? → `scripts/` e `tools/`
- Quer governança? → `policies/` e `terraform/`

---

## 📚 Fluxo Sugerido de Aprendizado

```
1. Cheat Sheet → 2. Labs → 3. Scripts → 4. Terraform → 5. Certificações
   Conceitos      Prática    Automação    Infra as       Validação
   rápidos        guiada     real         Code           profissional
```

1. **Cheat Sheet** (`CHEATSHEET.md`) — Absorva os conceitos e comandos essenciais
2. **Labs** (`labs/`) — Pratique com os 6 laboratórios guiados
3. **Scripts** (`scripts/`) — Aplique automações na sua conta real
4. **Terraform** (`terraform/`) — Implante governança como código
5. **Certificações** (`CERTIFICACOES.md`) — Valide seu conhecimento com AWS certs

---

## 🔧 Troubleshooting Comum

### ❌ Erro de permissão IAM

```
An error occurred (AccessDeniedException) when calling the GetCostAndUsage operation
```

**Solução**: Seu usuário precisa de acesso ao Cost Explorer:

```bash
# Verificar suas permissões atuais
aws iam list-attached-user-policies \
  --user-name $(aws sts get-caller-identity --query 'Arn' --output text | cut -d'/' -f2)

# Policies necessárias:
# - arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess
# - arn:aws:iam::aws:policy/CostExplorerReadOnlyAccess
```

### ❌ Região errada

```
Could not connect to the endpoint URL
```

**Solução**:

```bash
aws configure get region
aws configure set region us-east-1
```

### ❌ boto3 não instalado

```
ModuleNotFoundError: No module named 'boto3'
```

**Solução**:

```bash
pip3 install boto3 tabulate
```

### ❌ jq não encontrado

```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
sudo apt-get install jq
```

---

## 🔗 Links Rápidos

| Recurso | Descrição |
|---------|-----------|
| [CHEATSHEET.md](CHEATSHEET.md) | Referência rápida de comandos e conceitos |
| [FAQ.md](FAQ.md) | Perguntas frequentes dos alunos |
| [GLOSSARIO.md](GLOSSARIO.md) | Glossário de termos FinOps |
| [CERTIFICACOES.md](CERTIFICACOES.md) | Guia de estudo para certificações |
| [runbooks/](runbooks/) | Procedimentos para incidentes de custo |
| [Curso na Udemy](https://www.udemy.com/course/finops-na-aws-economizando-e-gerenciando-custos-na-nuvem/) | Acesso ao curso completo |
