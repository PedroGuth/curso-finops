"""Lambda que gera relatório diário de custos AWS dos últimos 7 dias.

Acionada por EventBridge (cron diário). Usa Cost Explorer API para buscar
custos por serviço e envia relatório formatado via SNS.

Variáveis de ambiente:
    SNS_TOPIC_ARN: ARN do tópico SNS para envio do relatório
    REPORT_DAYS: Dias para incluir no relatório (default: 7)
"""

import json
import logging
import os
from datetime import datetime, timedelta, timezone
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ce = boto3.client("ce")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
REPORT_DAYS = int(os.environ.get("REPORT_DAYS", "7"))


def get_cost_by_service(start: str, end: str) -> list[dict[str, Any]]:
    """Busca custos agrupados por serviço no período."""
    response = ce.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="DAILY",
        Metrics=["UnblendedCost"],
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}],
    )
    return response["ResultsByTime"]


def format_report(results: list[dict[str, Any]], start: str, end: str) -> str:
    """Formata os resultados em relatório texto."""
    totals: dict[str, float] = {}

    for day in results:
        for group in day["Groups"]:
            service = group["Keys"][0]
            amount = float(group["Metrics"]["UnblendedCost"]["Amount"])
            totals[service] = totals.get(service, 0.0) + amount

    sorted_services = sorted(totals.items(), key=lambda x: x[1], reverse=True)
    grand_total = sum(totals.values())

    lines = [
        "=" * 60,
        f"  RELATÓRIO DE CUSTOS AWS - Últimos {REPORT_DAYS} dias",
        f"  Período: {start} a {end}",
        "=" * 60,
        "",
        f"{'Serviço':<40} {'Custo (USD)':>12}",
        "-" * 54,
    ]

    for service, cost in sorted_services:
        if cost >= 0.01:
            lines.append(f"{service:<40} ${cost:>10.2f}")

    lines.extend([
        "-" * 54,
        f"{'TOTAL':<40} ${grand_total:>10.2f}",
        "",
        f"Gerado em: {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}",
    ])

    return "\n".join(lines)


def handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    """Handler principal da Lambda."""
    logger.info("Gerando relatório diário de custos")

    end = datetime.now(timezone.utc).date()
    start = end - timedelta(days=REPORT_DAYS)

    start_str = start.isoformat()
    end_str = end.isoformat()

    results = get_cost_by_service(start_str, end_str)
    report = format_report(results, start_str, end_str)

    logger.info(f"Relatório gerado:\n{report}")

    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"FinOps: Relatório de Custos AWS ({start_str} a {end_str})",
        Message=report,
    )

    logger.info("Relatório enviado via SNS")

    return {
        "statusCode": 200,
        "body": json.dumps({"period": f"{start_str}/{end_str}", "sent": True}),
    }
