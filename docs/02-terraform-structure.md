Task 2: Struktur Terraform

## Layout

```
terraform/
├── backend/
│   └── bootstrap/                # S3 + DynamoDB untuk remote state
├── modules/
│   ├── networking/
│   ├── storage_secrets/
│   ├── database/
│   ├── compute/
│   ├── cicd_pipeline/
│   └── monitoring/
└── environments/
    ├── staging/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── backend.hcl
    │   └── staging.tfvars.example
    └── production/
        ├── main.tf
        ├── variables.tf
        ├── backend.hcl
        └── production.tfvars.example
```

## Tanggung Jawab Module

| Module | Tujuan |
|--------|---------|
| `networking` | VPC, subnet public/private, NAT/IGW, route table, dan security group untuk ALB, aplikasi, database. |
| `storage_secrets` | Bucket upload S3 dan secret AWS Secrets Manager untuk aplikasi Laravel. |
| `database` | RDS MySQL (managed master password) dan cluster ElastiCache Redis, keduanya di private subnet. |
| `compute` | ALB dengan target group backend/frontend, launch template, Auto Scaling Group, IAM instance profile, dan bootstrap user-data. |
| `cicd_pipeline` | Repository ECR dengan lifecycle policy, CodeStar Connection, CodeBuild project, CodeDeploy app/group, dan CodePipeline pipeline. |
| `monitoring` | CloudWatch log group dan metric alarm (unhealthy host ALB, 5xx, latency, CPU ASG) plus SNS topic. |

## Perbedaan Environment

| Item | Staging | Production |
|------|---------|------------|
| VPC CIDR | 10.10.0.0/16 | 10.20.0.0/16 |
| RDS Multi-AZ | false | true |
| Redis nodes | 1 | 2 |
| ASG desired | 1 | 2 |
| ASG min/max | 1/2 | 2/4 |
| Backup retention | default 7 hari | 14 hari |
| Deletion protection | false | true |
| Final snapshot | dilewati | dibuat |

## Remote State

- Bucket state: `dat-laravel-tfstate-ap-southeast-1`
- Tabel lock: `dat-laravel-tflocks`
- Key staging: `laravel/staging/terraform.tfstate`
- Key production: `laravel/production/terraform.tfstate`

## Alur Deployment

1. Bootstrap backend terlebih dahulu:
   ```bash
   cd terraform/backend/bootstrap
   terraform init
   terraform apply
   ```
2. Deploy environment:
   ```bash
   cd terraform/environments/staging
   terraform init -backend-config=backend.hcl
   terraform plan -var-file=staging.tfvars
   terraform apply -var-file=staging.tfvars
   ```

## Asumsi dan Langkah Manual

- Kredensial AWS CLI dan default region harus dikonfigurasi secara lokal atau melalui environment variable.
- CodeStar Connection yang dibuat oleh Terraform akan berstatus `PENDING`; authorize melalui AWS Console sebelum pipeline dapat mengambil kode dari GitHub.
- Application secret dibuat kosong. Simpan nilai Laravel `.env` yang sebenarnya (APP_KEY, database URL, API keys) di AWS Secrets Manager setelah provisioning.
- HTTPS dan custom domain tidak termasuk secara default; tambahkan ACM dan HTTPS listener jika domain production tersedia.
