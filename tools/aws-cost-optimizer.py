#!/usr/bin/env python3
"""
AWS Cost Optimizer - Script de Otimização Automática de Custos
==============================================================
Analisa sua conta AWS e identifica oportunidades de economia em:
- EC2: instâncias ociosas, gerações antigas, volumes gp2
- EBS: volumes não anexados, snapshots órfãos
- EIPs: Elastic IPs não associados
- RDS: instâncias ociosas
- S3: buckets sem lifecycle policy

Uso:
    python aws-cost-optimizer.py [--region us-east-1] [--profile default] [--fix]

Requisitos:
    pip install boto3 tabulate
"""

import argparse
import json
from datetime import datetime, timedelta, timezone
from typing import Any

import boto3
from tabulate import tabulate


class CostOptimizer:
    """Analisa recursos AWS e identifica oportunidades de economia."""

    def __init__(self, region: str, profile: str | None = None):
        session = boto3.Session(region_name=region, profile_name=profile)
        self.ec2 = session.client("ec2")
        self.cloudwatch = session.client("cloudwatch")
        self.rds = session.client("rds")
        self.s3 = session.client("s3")
        self.region = region
        self.findings: list[dict[str, Any]] = []

    def analyze_all(self) -> None:
        """Executa todas as análises."""
        print(f"\n🔍 Analisando região: {self.region}\n")
        self._check_idle_ec2()
        self._check_old_gen_ec2()
        self._check_gp2_volumes()
        self._check_unattached_volumes()
        self._check_orphan_snapshots()
        self._check_unused_eips()
        self._check_idle_rds()
        self._check_s3_no_lifecycle()

    def _check_idle_ec2(self) -> None:
        """Identifica instâncias EC2 com CPU < 5% nos últimos 7 dias."""
        print("  ⏳ Verificando instâncias EC2 ociosas...")
        instances = self.ec2.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        for reservation in instances["Reservations"]:
            for inst in reservation["Instances"]:
                instance_id = inst["InstanceId"]
                instance_type = inst["InstanceType"]
                avg_cpu = self._get_avg_cpu(instance_id)
                if avg_cpu is not None and avg_cpu < 5.0:
                    name = self._get_tag(inst.get("Tags", []), "Name")
                    self.findings.append({
                        "categoria": "EC2 Ociosa",
                        "recurso": f"{instance_id} ({name})",
                        "detalhe": f"CPU média: {avg_cpu:.1f}% | Tipo: {instance_type}",
                        "acao": "Redimensionar ou desligar",
                        "economia_mensal": self._estimate_ec2_cost(instance_type),
                    })

    def _check_old_gen_ec2(self) -> None:
        """Identifica instâncias de gerações antigas (t2, m4, c4, r4)."""
        print("  ⏳ Verificando instâncias de geração antiga...")
        old_prefixes = ("t2.", "m4.", "c4.", "r4.", "m3.", "c3.", "r3.")
        instances = self.ec2.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        for reservation in instances["Reservations"]:
            for inst in reservation["Instances"]:
                itype = inst["InstanceType"]
                if itype.startswith(old_prefixes):
                    name = self._get_tag(inst.get("Tags", []), "Name")
                    self.findings.append({
                        "categoria": "EC2 Geração Antiga",
                        "recurso": f"{inst['InstanceId']} ({name})",
                        "detalhe": f"Tipo: {itype}",
                        "acao": "Migrar para última geração (~20% economia)",
                        "economia_mensal": "~20% do custo atual",
                    })

    def _check_gp2_volumes(self) -> None:
        """Identifica volumes EBS gp2 que podem ser migrados para gp3."""
        print("  ⏳ Verificando volumes gp2...")
        volumes = self.ec2.describe_volumes(
            Filters=[{"Name": "volume-type", "Values": ["gp2"]}]
        )
        for vol in volumes["Volumes"]:
            self.findings.append({
                "categoria": "EBS gp2 → gp3",
                "recurso": f"{vol['VolumeId']} ({vol['Size']} GB)",
                "detalhe": f"Estado: {vol['State']}",
                "acao": "Migrar para gp3 (mesmo desempenho, 20% mais barato)",
                "economia_mensal": f"${vol['Size'] * 0.02:.2f}",
            })

    def _check_unattached_volumes(self) -> None:
        """Identifica volumes EBS não anexados a nenhuma instância."""
        print("  ⏳ Verificando volumes não anexados...")
        volumes = self.ec2.describe_volumes(
            Filters=[{"Name": "status", "Values": ["available"]}]
        )
        for vol in volumes["Volumes"]:
            vtype = vol["VolumeType"]
            size = vol["Size"]
            price_per_gb = {"gp2": 0.10, "gp3": 0.08, "io1": 0.125, "io2": 0.125, "st1": 0.045, "sc1": 0.015}
            cost = size * price_per_gb.get(vtype, 0.10)
            self.findings.append({
                "categoria": "EBS Não Anexado",
                "recurso": f"{vol['VolumeId']} ({size} GB, {vtype})",
                "detalhe": f"Criado em: {vol['CreateTime'].strftime('%Y-%m-%d')}",
                "acao": "Snapshot + deletar volume",
                "economia_mensal": f"${cost:.2f}",
            })

    def _check_orphan_snapshots(self) -> None:
        """Identifica snapshots cujo volume de origem não existe mais."""
        print("  ⏳ Verificando snapshots órfãos...")
        account_id = boto3.client("sts").get_caller_identity()["Account"]
        snapshots = self.ec2.describe_snapshots(OwnerIds=[account_id])
        volume_ids = {v["VolumeId"] for v in self.ec2.describe_volumes()["Volumes"]}

        orphan_count = 0
        orphan_size = 0
        for snap in snapshots["Snapshots"]:
            if snap["VolumeId"] not in volume_ids:
                orphan_count += 1
                orphan_size += snap["VolumeSize"]

        if orphan_count > 0:
            self.findings.append({
                "categoria": "Snapshots Órfãos",
                "recurso": f"{orphan_count} snapshots ({orphan_size} GB total)",
                "detalhe": "Volumes de origem não existem mais",
                "acao": "Revisar e deletar desnecessários",
                "economia_mensal": f"${orphan_size * 0.05:.2f}",
            })

    def _check_unused_eips(self) -> None:
        """Identifica Elastic IPs não associados."""
        print("  ⏳ Verificando Elastic IPs não associados...")
        addresses = self.ec2.describe_addresses()
        for addr in addresses["Addresses"]:
            if "AssociationId" not in addr:
                self.findings.append({
                    "categoria": "EIP Não Associado",
                    "recurso": f"{addr['PublicIp']} ({addr['AllocationId']})",
                    "detalhe": "Elastic IP sem instância associada",
                    "acao": "Liberar EIP",
                    "economia_mensal": "$3.65",
                })

    def _check_idle_rds(self) -> None:
        """Identifica instâncias RDS com 0 conexões nos últimos 7 dias."""
        print("  ⏳ Verificando instâncias RDS ociosas...")
        dbs = self.rds.describe_db_instances()
        for db in dbs["DBInstances"]:
            if db["DBInstanceStatus"] != "available":
                continue
            connections = self._get_rds_connections(db["DBInstanceIdentifier"])
            if connections is not None and connections == 0:
                self.findings.append({
                    "categoria": "RDS Ociosa",
                    "recurso": f"{db['DBInstanceIdentifier']} ({db['DBInstanceClass']})",
                    "detalhe": f"0 conexões nos últimos 7 dias | Engine: {db['Engine']}",
                    "acao": "Snapshot + deletar ou parar",
                    "economia_mensal": "Varia por classe",
                })

    def _check_s3_no_lifecycle(self) -> None:
        """Identifica buckets S3 sem política de lifecycle."""
        print("  ⏳ Verificando buckets S3 sem lifecycle...")
        buckets = self.s3.list_buckets()
        for bucket in buckets["Buckets"]:
            try:
                self.s3.get_bucket_lifecycle_configuration(Bucket=bucket["Name"])
            except self.s3.exceptions.ClientError:
                self.findings.append({
                    "categoria": "S3 Sem Lifecycle",
                    "recurso": bucket["Name"],
                    "detalhe": "Sem regra de transição ou expiração",
                    "acao": "Configurar lifecycle (Standard → IA → Glacier)",
                    "economia_mensal": "Até 90% em storage antigo",
                })

    def _get_avg_cpu(self, instance_id: str) -> float | None:
        """Retorna CPU média dos últimos 7 dias."""
        end = datetime.now(timezone.utc)
        start = end - timedelta(days=7)
        response = self.cloudwatch.get_metric_statistics(
            Namespace="AWS/EC2",
            MetricName="CPUUtilization",
            Dimensions=[{"Name": "InstanceId", "Value": instance_id}],
            StartTime=start,
            EndTime=end,
            Period=86400,
            Statistics=["Average"],
        )
        datapoints = response.get("Datapoints", [])
        if not datapoints:
            return None
        return sum(d["Average"] for d in datapoints) / len(datapoints)

    def _get_rds_connections(self, db_id: str) -> float | None:
        """Retorna média de conexões RDS nos últimos 7 dias."""
        end = datetime.now(timezone.utc)
        start = end - timedelta(days=7)
        response = self.cloudwatch.get_metric_statistics(
            Namespace="AWS/RDS",
            MetricName="DatabaseConnections",
            Dimensions=[{"Name": "DBInstanceIdentifier", "Value": db_id}],
            StartTime=start,
            EndTime=end,
            Period=86400,
            Statistics=["Average"],
        )
        datapoints = response.get("Datapoints", [])
        if not datapoints:
            return None
        return sum(d["Average"] for d in datapoints) / len(datapoints)

    @staticmethod
    def _get_tag(tags: list, key: str) -> str:
        """Extrai valor de uma tag."""
        for tag in tags:
            if tag["Key"] == key:
                return tag["Value"]
        return "sem-nome"

    @staticmethod
    def _estimate_ec2_cost(instance_type: str) -> str:
        """Estimativa grosseira de custo mensal por tipo."""
        estimates = {
            "t3.micro": "$7.59", "t3.small": "$15.18", "t3.medium": "$30.37",
            "t3.large": "$60.74", "m5.large": "$70.08", "m5.xlarge": "$140.16",
            "c5.large": "$62.05", "c5.xlarge": "$124.10",
        }
        return estimates.get(instance_type, "Consultar pricing")

    def report(self) -> None:
        """Exibe relatório formatado."""
        if not self.findings:
            print("\n✅ Nenhuma oportunidade de otimização encontrada! Parabéns! 🎉")
            return

        print(f"\n{'='*80}")
        print(f"📊 RELATÓRIO DE OTIMIZAÇÃO DE CUSTOS")
        print(f"{'='*80}")
        print(f"Região: {self.region}")
        print(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
        print(f"Oportunidades encontradas: {len(self.findings)}")
        print(f"{'='*80}\n")

        table_data = []
        for f in self.findings:
            table_data.append([
                f["categoria"],
                f["recurso"],
                f["acao"],
                f["economia_mensal"],
            ])

        print(tabulate(
            table_data,
            headers=["Categoria", "Recurso", "Ação Recomendada", "Economia/mês"],
            tablefmt="grid",
            maxcolwidths=[20, 35, 40, 15],
        ))

        print(f"\n💡 Execute com --fix para aplicar correções automáticas (gp2→gp3, EIPs).")
        print(f"⚠️  Sempre revise antes de aplicar em produção!\n")

    def export_json(self, filename: str = "cost-optimization-report.json") -> None:
        """Exporta relatório em JSON."""
        report = {
            "region": self.region,
            "date": datetime.now().isoformat(),
            "total_findings": len(self.findings),
            "findings": self.findings,
        }
        with open(filename, "w") as f:
            json.dump(report, f, indent=2, default=str)
        print(f"📁 Relatório exportado: {filename}")

    def auto_fix(self) -> None:
        """Aplica correções automáticas seguras (gp2→gp3, liberar EIPs)."""
        print("\n🔧 Aplicando correções automáticas...\n")
        for f in self.findings:
            if f["categoria"] == "EBS gp2 → gp3":
                vol_id = f["recurso"].split(" ")[0]
                print(f"  🔄 Migrando {vol_id} para gp3...")
                self.ec2.modify_volume(VolumeId=vol_id, VolumeType="gp3")
                print(f"     ✅ Migrado")
            elif f["categoria"] == "EIP Não Associado":
                alloc_id = f["recurso"].split("(")[1].rstrip(")")
                print(f"  🗑️  Liberando EIP {alloc_id}...")
                self.ec2.release_address(AllocationId=alloc_id)
                print(f"     ✅ Liberado")


def main():
    parser = argparse.ArgumentParser(description="AWS Cost Optimizer - Otimização automática de custos")
    parser.add_argument("--region", default="us-east-1", help="Região AWS (default: us-east-1)")
    parser.add_argument("--profile", default=None, help="AWS profile (default: default)")
    parser.add_argument("--fix", action="store_true", help="Aplicar correções automáticas (gp2→gp3, EIPs)")
    parser.add_argument("--json", action="store_true", help="Exportar relatório em JSON")
    args = parser.parse_args()

    optimizer = CostOptimizer(region=args.region, profile=args.profile)
    optimizer.analyze_all()
    optimizer.report()

    if args.json:
        optimizer.export_json()

    if args.fix:
        optimizer.auto_fix()


if __name__ == "__main__":
    main()
