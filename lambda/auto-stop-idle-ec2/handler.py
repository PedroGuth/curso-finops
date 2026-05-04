"""Lambda que para instâncias EC2 ociosas (CPU < 5% nos últimos 7 dias).

Variáveis de ambiente:
    SNS_TOPIC_ARN: ARN do tópico SNS para notificações
    CPU_THRESHOLD: Limite de CPU (default: 5.0)
    EVALUATION_DAYS: Dias para avaliar (default: 7)
"""

import json
import logging
import os
from datetime import datetime, timedelta, timezone
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")
cloudwatch = boto3.client("cloudwatch")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
CPU_THRESHOLD = float(os.environ.get("CPU_THRESHOLD", "5.0"))
EVALUATION_DAYS = int(os.environ.get("EVALUATION_DAYS", "7"))


def get_average_cpu(instance_id: str) -> float | None:
    """Retorna a média de CPU da instância nos últimos N dias."""
    end = datetime.now(timezone.utc)
    start = end - timedelta(days=EVALUATION_DAYS)

    response = cloudwatch.get_metric_statistics(
        Namespace="AWS/EC2",
        MetricName="CPUUtilization",
        Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
        StartTime=start,
        EndTime=end,
        Period=EVALUATION_DAYS * 86400,
        Statistics=["Average"],
    )

    datapoints = response.get("Datapoints", [])
    if not datapoints:
        return None
    return datapoints[0]["Average"]


def should_skip(tags: list[dict[str, str]]) -> bool:
    """Verifica se a instância tem tag AutoStop=false."""
    for tag in tags:
        if tag.get("Key") == "AutoStop" and tag.get("Value", "").lower() == "false":
            return True
    return False


def handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    """Handler principal da Lambda."""
    logger.info("Iniciando verificação de instâncias ociosas")

    instances = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )

    stopped: list[str] = []
    skipped: list[str] = []

    for reservation in instances["Reservations"]:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            tags = instance.get("Tags", [])

            if should_skip(tags):
                logger.info(f"{instance_id}: ignorada (AutoStop=false)")
                skipped.append(instance_id)
                continue

            avg_cpu = get_average_cpu(instance_id)

            if avg_cpu is None:
                logger.warning(f"{instance_id}: sem dados de CPU")
                continue

            if avg_cpu < CPU_THRESHOLD:
                name = next((t["Value"] for t in tags if t["Key"] == "Name"), "N/A")
                logger.info(f"{instance_id} ({name}): CPU média {avg_cpu:.2f}% - parando")

                sns.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject="FinOps: Instância EC2 ociosa será parada",
                    Message=(
                        f"Instância: {instance_id} ({name})\n"
                        f"CPU média ({EVALUATION_DAYS}d): {avg_cpu:.2f}%\n"
                        f"Threshold: {CPU_THRESHOLD}%\n"
                        f"Ação: Stop"
                    ),
                )

                ec2.stop_instances(InstanceIds=[instance_id])
                stopped.append(instance_id)
            else:
                logger.info(f"{instance_id}: CPU média {avg_cpu:.2f}% - OK")

    logger.info(f"Resultado: {len(stopped)} paradas, {len(skipped)} ignoradas")

    return {
        "statusCode": 200,
        "body": json.dumps({"stopped": stopped, "skipped": skipped}),
    }
