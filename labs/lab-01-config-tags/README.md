# Lab 01 – Controlar Recursos com Marcação (Tags) e AWS Config

## Objetivo

Garantir que todos os recursos EC2 sigam padrões de marcação e tipos de instância aprovados, usando AWS Config para detectar e corrigir não conformidades automaticamente, e IAM para prevenir criação de recursos fora do padrão.

## Serviços Utilizados

| Serviço | Função no Lab |
|---------|---------------|
| AWS Config | Avaliar conformidade de recursos e remediar automaticamente |
| IAM | Impedir criação de recursos sem tags obrigatórias |
| EC2 | Recurso-alvo das regras de conformidade |

## Arquitetura

O ambiente consiste em uma VPC com sub-rede pública (servidor web) e sub-rede privada (servidor de banco de dados). O AWS Config monitora continuamente as instâncias EC2 com duas regras gerenciadas:

- **required-tags** – verifica se as tags `Department`, `Application` e `Environment` estão presentes com valores válidos.
- **desired-instance-type** – verifica se instâncias de produção usam exclusivamente `t3.medium`.

Quando uma instância de produção usa tipo incorreto, o Config aciona uma remediação automática via SSM Automation. Paralelamente, uma política IAM impede que usuários criem instâncias sem as tags obrigatórias.

## Passo a Passo

### 1. Ativar o AWS Config

1. Acesse **AWS Config > Settings**.
2. Clique em **Turn on AWS Config**.
3. Em **Resource types to record**, selecione **Specific types** e escolha `AWS::EC2::Instance`.
4. Defina a frequência de entrega como **Continuous**.
5. Crie ou selecione um bucket S3 para armazenar o histórico.
6. Crie ou selecione uma IAM Role para o Config.
7. Clique em **Confirm**.

### 2. Criar Regra RequiredTagsCompliance

1. Vá em **AWS Config > Rules > Add rule**.
2. Pesquise e selecione a regra gerenciada **required-tags**.
3. Nomeie como `RequiredTagsCompliance`.
4. Configure os parâmetros:
   - `tag1Key` = `Department` / `tag1Value` = `Finance`
   - `tag2Key` = `Application` / `tag2Value` = `Accounts Payable`
   - `tag3Key` = `Environment` / `tag3Value` = `Development,Test,Production`
5. Salve a regra.

### 3. Criar Regra ProductionInstanceType

1. Adicione nova regra gerenciada **desired-instance-type**.
2. Nomeie como `ProductionInstanceType`.
3. Em **Scope of changes**, selecione **Tags** e defina `Environment` = `Production`.
4. No parâmetro `instanceType`, informe `t3.medium`.
5. Salve a regra.

### 4. Adicionar Remediação Automática

1. Selecione a regra `ProductionInstanceType`.
2. Clique em **Actions > Manage remediation**.
3. Escolha **Automatic remediation**.
4. Selecione o documento SSM `AWS-StopEC2Instance` (para forçar parada de instâncias não conformes).
5. Configure o parâmetro `InstanceId` com o valor do recurso.
6. Defina tentativas: 5, com intervalo de 60 segundos.
7. Salve.

### 5. Criar Política IAM para Exigir Tags

Crie a política abaixo e anexe ao grupo/usuário desejado:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowRunInstancesWithTags",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Department": "Finance",
          "aws:RequestTag/Environment": ["Development", "Test", "Production"]
        },
        "StringLike": {
          "aws:RequestTag/Application": "*"
        }
      }
    },
    {
      "Sid": "AllowRunInstancesOtherResources",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*::image/*"
      ]
    },
    {
      "Sid": "AllowCreateTagsOnLaunch",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "RunInstances"
        }
      }
    }
  ]
}
```

### 6. Testar a Conformidade

**Teste 1 – Sem tags (deve falhar):**

```bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro \
  --subnet-id subnet-xxx \
  --tag-specifications 'ResourceType=instance,Tags=[]'
```

Resultado esperado: `UnauthorizedOperation`.

**Teste 2 – Com tags (deve funcionar):**

```bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.micro \
  --subnet-id subnet-xxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Department,Value=Finance},{Key=Application,Value=Accounts Payable},{Key=Environment,Value=Development}]'
```

### 7. Verificar Conformidade no Dashboard

1. Acesse **AWS Config > Dashboard**.
2. Verifique o status das regras `RequiredTagsCompliance` e `ProductionInstanceType`.
3. Clique em cada regra para ver recursos conformes e não conformes.
4. Confirme que a remediação automática parou instâncias de produção com tipo incorreto.

## Dicas de Economia

- **Tags são a base de tudo em FinOps.** Sem tags consistentes, é impossível alocar custos por equipe, projeto ou ambiente.
- **Use o Config apenas para os tipos de recurso necessários** – gravar tudo gera custos desnecessários de avaliação e armazenamento.
- **Regras gerenciadas são gratuitas até 25 avaliações/mês por regra** na camada gratuita. Acima disso, cada avaliação custa US$ 0,001.
- **Prevenir é mais barato que remediar.** A política IAM evita que recursos não conformes sequer existam, eliminando custo de remediação.
- **Combine com AWS Organizations Tag Policies** para governança em escala multi-conta.
