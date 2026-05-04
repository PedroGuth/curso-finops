#!/usr/bin/env python3
"""
Reserved Instances Calculator - Calculadora de Economia com RIs e Savings Plans
================================================================================
Analisa o uso atual de EC2 e calcula a economia potencial com:
- Reserved Instances (Standard e Convertible)
- Savings Plans (Compute e EC2 Instance)
- Diferentes opções de pagamento (No Upfront, Partial, All Upfront)

Uso:
    python reserved-instances-calculator.py [--region us-east-1] [--term 1|3]

Requisitos:
    pip install boto3 tabulate
"""

import argparse
from datetime import datetime, timedelta, timezone

import boto3
from tabulate import tabulate

# Preços aproximados por hora (us-east-1, Linux) - Atualizar conforme necessário
PRICING = {
    "t3.micro":   {"on_demand": 0.0104, "ri_1yr_no": 0.0074, "ri_1yr_all": 0.0063, "ri_3yr_all": 0.0040, "sp_compute_1yr": 0.0078, "sp_ec2_1yr": 0.0068},
    "t3.small":   {"on_demand": 0.0208, "ri_1yr_no": 0.0148, "ri_1yr_all": 0.0126, "ri_3yr_all": 0.0080, "sp_compute_1yr": 0.0156, "sp_ec2_1yr": 0.0136},
    "t3.medium":  {"on_demand": 0.0416, "ri_1yr_no": 0.0296, "ri_1yr_all": 0.0252, "ri_3yr_all": 0.0160, "sp_compute_1yr": 0.0312, "sp_ec2_1yr": 0.0272},
    "t3.large":   {"on_demand": 0.0832, "ri_1yr_no": 0.0592, "ri_1yr_all": 0.0504, "ri_3yr_all": 0.0320, "sp_compute_1yr": 0.0624, "sp_ec2_1yr": 0.0544},
    "t3.xlarge":  {"on_demand": 0.1664, "ri_1yr_no": 0.1184, "ri_1yr_all": 0.1008, "ri_3yr_all": 0.0640, "sp_compute_1yr": 0.1248, "sp_ec2_1yr": 0.1088},
    "m5.large":   {"on_demand": 0.0960, "ri_1yr_no": 0.0590, "ri_1yr_all": 0.0515, "ri_3yr_all": 0.0330, "sp_compute_1yr": 0.0620, "sp_ec2_1yr": 0.0540},
    "m5.xlarge":  {"on_demand": 0.1920, "ri_1yr_no": 0.1180, "ri_1yr_all": 0.1030, "ri_3yr_all": 0.0660, "sp_compute_1yr": 0.1240, "sp_ec2_1yr": 0.1080},
    "m5.2xlarge": {"on_demand": 0.3840, "ri_1yr_no": 0.2360, "ri_1yr_all": 0.2060, "ri_3yr_all": 0.1320, "sp_compute_1yr": 0.2480, "sp_ec2_1yr": 0.2160},
    "c5.large":   {"on_demand": 0.0850, "ri_1yr_no": 0.0530, "ri_1yr_all": 0.0460, "ri_3yr_all": 0.0290, "sp_compute_1yr": 0.0560, "sp_ec2_1yr": 0.0480},
    "c5.xlarge":  {"on_demand": 0.1700, "ri_1yr_no": 0.1060, "ri_1yr_all": 0.0920, "ri_3yr_all": 0.0580, "sp_compute_1yr": 0.1120, "sp_ec2_1yr": 0.0960},
    "r5.large":   {"on_demand": 0.1260, "ri_1yr_no": 0.0790, "ri_1yr_all": 0.0680, "ri_3yr_all": 0.0430, "sp_compute_1yr": 0.0830, "sp_ec2_1yr": 0.0720},
    "r5.xlarge":  {"on_demand": 0.2520, "ri_1yr_no": 0.1580, "ri_1yr_all": 0.1360, "ri_3yr_all": 0.0860, "sp_compute_1yr": 0.1660, "sp_ec2_1yr": 0.1440},
}

HOURS_PER_MONTH = 730
HOURS_PER_YEAR = 8760


def get_running_instances(region: str, profile: str | None = None) -> dict:
    """Retorna contagem de instâncias por tipo."""
    session = boto3.Session(region_name=region, profile_name=profile)
    ec2 = session.client("ec2")

    instances = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )

    counts = {}
    for reservation in instances["Reservations"]:
        for inst in reservation["Instances"]:
            itype = inst["InstanceType"]
            counts[itype] = counts.get(itype, 0) + 1

    return counts


def calculate_savings(instance_type: str, count: int) -> dict | None:
    """Calcula economia para um tipo de instância."""
    if instance_type not in PRICING:
        return None

    p = PRICING[instance_type]
    monthly_on_demand = p["on_demand"] * HOURS_PER_MONTH * count

    results = {
        "instance_type": instance_type,
        "count": count,
        "monthly_on_demand": monthly_on_demand,
        "options": []
    }

    options = [
        ("RI Standard 1yr (No Upfront)", p["ri_1yr_no"]),
        ("RI Standard 1yr (All Upfront)", p["ri_1yr_all"]),
        ("RI Standard 3yr (All Upfront)", p["ri_3yr_all"]),
        ("Compute Savings Plan 1yr", p["sp_compute_1yr"]),
        ("EC2 Instance SP 1yr", p["sp_ec2_1yr"]),
    ]

    for name, rate in options:
        monthly_cost = rate * HOURS_PER_MONTH * count
        monthly_savings = monthly_on_demand - monthly_cost
        pct_savings = (monthly_savings / monthly_on_demand) * 100 if monthly_on_demand > 0 else 0
        results["options"].append({
            "name": name,
            "monthly_cost": monthly_cost,
            "monthly_savings": monthly_savings,
            "pct_savings": pct_savings,
        })

    return results


def print_report(all_results: list, region: str) -> None:
    """Imprime relatório formatado."""
    print(f"\n{'='*90}")
    print(f"💰 CALCULADORA DE RESERVED INSTANCES & SAVINGS PLANS")
    print(f"{'='*90}")
    print(f"Região: {region}")
    print(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print(f"{'='*90}\n")

    total_on_demand = 0
    best_total_savings = 0

    for result in all_results:
        total_on_demand += result["monthly_on_demand"]

        print(f"\n📦 {result['instance_type']} × {result['count']} instância(s)")
        print(f"   Custo On-Demand: ${result['monthly_on_demand']:.2f}/mês")
        print(f"   {'─'*70}")

        table_data = []
        best_saving = 0
        for opt in result["options"]:
            table_data.append([
                opt["name"],
                f"${opt['monthly_cost']:.2f}",
                f"${opt['monthly_savings']:.2f}",
                f"{opt['pct_savings']:.0f}%",
            ])
            best_saving = max(best_saving, opt["monthly_savings"])

        best_total_savings += best_saving

        print(tabulate(
            table_data,
            headers=["Opção", "Custo/mês", "Economia/mês", "% Desconto"],
            tablefmt="simple",
            stralign="right",
        ))

    print(f"\n{'='*90}")
    print(f"📊 RESUMO")
    print(f"{'='*90}")
    print(f"  Custo total On-Demand:      ${total_on_demand:.2f}/mês (${total_on_demand*12:.2f}/ano)")
    print(f"  Melhor economia possível:   ${best_total_savings:.2f}/mês (${best_total_savings*12:.2f}/ano)")
    print(f"  Percentual de economia:     {(best_total_savings/total_on_demand*100) if total_on_demand > 0 else 0:.0f}%")
    print(f"{'='*90}")

    print(f"\n💡 Recomendações:")
    print(f"  • Para cargas estáveis e previsíveis → RI Standard 1yr All Upfront")
    print(f"  • Para flexibilidade entre famílias  → Compute Savings Plan")
    print(f"  • Para compromisso mínimo            → RI 1yr No Upfront")
    print(f"  • Compre em ciclos pequenos para minimizar risco")
    print(f"  • Use Cost Explorer > Recommendations para dados reais da AWS\n")


def main():
    parser = argparse.ArgumentParser(description="Calculadora de Reserved Instances e Savings Plans")
    parser.add_argument("--region", default="us-east-1", help="Região AWS")
    parser.add_argument("--profile", default=None, help="AWS profile")
    parser.add_argument("--simulate", nargs="+", help="Simular tipos (ex: --simulate t3.large:3 m5.xlarge:2)")
    args = parser.parse_args()

    if args.simulate:
        # Modo simulação sem precisar de conta AWS
        counts = {}
        for item in args.simulate:
            itype, count = item.split(":")
            counts[itype] = int(count)
        print("🧪 Modo simulação (sem consultar AWS)")
    else:
        print(f"🔍 Consultando instâncias em {args.region}...")
        counts = get_running_instances(args.region, args.profile)

    if not counts:
        print("⚠️  Nenhuma instância encontrada.")
        print("💡 Use --simulate para testar: python reserved-instances-calculator.py --simulate t3.large:3 m5.xlarge:2")
        return

    all_results = []
    unsupported = []
    for itype, count in sorted(counts.items()):
        result = calculate_savings(itype, count)
        if result:
            all_results.append(result)
        else:
            unsupported.append(f"{itype} × {count}")

    if all_results:
        print_report(all_results, args.region)

    if unsupported:
        print(f"⚠️  Tipos sem dados de preço (adicione ao PRICING): {', '.join(unsupported)}")


if __name__ == "__main__":
    main()
