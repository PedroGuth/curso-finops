"""Lambda que verifica tags obrigatórias em instâncias EC2 recém-criadas.

Acionada por EventBridge (evento ec2:RunInstances).
Para a instância e notifica via SNS se tags obrigatórias estiverem ausentes.

Variáveis de ambiente:
    SNS_TOPIC_ARN: ARN do tópico SNS para notificações
    REQUIRED_TAGS: Tags obrigatórias separadas por vírgula (default: Department,Environment,Application)
"""

import json
import logging
import os
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
REQUIRED_TAGS = os.environ.get("REQUIRED_TAGS", "Department,Environment,Application").split(",")


def get_instance_tags(instance_id: str) -> dict[str, str]:
    """Retorna as tags da instância como dicionário."""
    response = ec2.describe_instances(InstanceIds=[instance_id])
    tags = response["Reservations"][0]["Instances"][0].get("Tags", [])
    return {t["Key"]: t["Value"] for t in tags}


def handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    """Handler principal da Lambda."""
    logger.info(f"Evento recebido: {json.dumps(event)}")

    detail = event.get("detail", {})
    items = detail.get("responseElements", {}).get("instancesSet", {}).get("items", [])

    results: list[dict[str, Any]] = []

    for item in items:
        instance_id = item["instanceId"]
        logger.info(f"Verificando tags de {instance_id}")

        tags = get_instance_tags(instance_id)
        missing = [t for t in REQUIRED_TAGS if t not in tags]

        if not missing:
            logger.info(f"{instance_id}: todas as tags obrigatórias presentes")
            results.append({"instance_id": instance_id, "compliant": True})
            continue

        logger.warning(f"{instance_id}: tags ausentes: {missing}")

        user = detail.get("userIdentity", {}).get("arn", "desconhecido")

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="FinOps: Instância EC2 sem tags obrigatórias - PARADA",
            Message=(
                f"Instância: {instance_id}\n"
                f"Tags ausentes: {', '.join(missing)}\n"
                f"Criada por: {user}\n"
                f"Ação: instância parada por non-compliance"
            ),
        )

        ec2.stop_instances(InstanceIds=[instance_id])
        logger.info(f"{instance_id}: parada por falta de tags")
        results.append({"instance_id": instance_id, "compliant": False, "missing_tags": missing})

    return {
        "statusCode": 200,
        "body": json.dumps(results),
    }
