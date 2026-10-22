# Technical Test – DevOps Engineer - SILAKAN DIGUNAKAN

Submission untuk technical test DevOps Engineer PT. Darmawan Aryansah Teknologi.

## Layout Folder

```
darmawan/
├── docs/
│   ├── 01-cicd-flow.md              # Task 1: arsitektur dan alur CI/CD
│   ├── 02-terraform-structure.md    # Task 2: struktur dan penggunaan Terraform
│   └── 03-monitoring-alerting.md    # Task 3: monitoring dan alerting (bonus)
├── ci/
│   ├── buildspec.yml                # buildspec CodeBuild yang dibagi
│   ├── appspec.yml                  # appspec CodeDeploy yang dibagi
│   └── scripts/                     # lifecycle hooks CodeDeploy yang dibagi
│       ├── stop-container.sh
│       ├── deploy-container.sh
│       └── validate-service.sh
├── terraform/
│   ├── backend/
│   │   └── bootstrap/               # bootstrap S3 + DynamoDB untuk remote state
│   ├── modules/                     # module Terraform yang reusable
│   │   ├── networking
│   │   ├── storage_secrets
│   │   ├── database
│   │   ├── compute
│   │   ├── cicd_pipeline
│   │   └── monitoring
│   └── environments/                # root Terraform per environment
│       ├── staging
│       └── production
└── README.md
```

## Quick Start

### 1. Bootstrap backend remote state Terraform

```bash
cd terraform/backend/bootstrap
terraform init
terraform apply
```

### 2. Deploy sebuah environment (contoh: staging)

Salin dan isi contoh tfvars:

```bash
cd terraform/environments/staging
cp staging.tfvars.example staging.tfvars
# edit staging.tfvars dengan AWS account ID, owner GitHub, nama repository, image URI, dan email alert Anda
terraform init -backend-config=backend.hcl
terraform plan -var-file=staging.tfvars
terraform apply -var-file=staging.tfvars
```

### 3. Authorize koneksi GitHub

Terraform membuat AWS CodeStar Connection ke GitHub. Sebelum pipeline dapat mengambil kode:

1. Buka AWS Console → Developer Tools → CodeStar Connections.
2. Cari connection bernama `<env-name>-github`.
3. Klik **Update pending connection** dan authorize organisasi/repository GitHub.

### 4. Tambahkan file deployment ke setiap repository

Salin file CI yang dibagi ke repository backend dan frontend:

```bash
cp -r ci/buildspec.yml ci/appspec.yml ci/scripts laravel-backend/
cp -r ci/buildspec.yml ci/appspec.yml ci/scripts laravel-frontend/
```

Jadikan script dapat dieksekusi, lalu push file-file ini ke branch yang dikonfigurasi di `github_branch` (default `main`):

```bash
chmod +x laravel-backend/scripts/*.sh laravel-frontend/scripts/*.sh
```

### 5. Hapus resource saat tidak diperlukan lagi

```bash
cd terraform/environments/staging
terraform destroy -var-file=staging.tfvars
```

## Catatan

- Kredensial AWS dan region diharapkan sudah dikonfigurasi secara lokal atau melalui environment variable.
- Terraform state disimpan di S3 dengan state locking DynamoDB.
- Secret dikelola dengan AWS Secrets Manager; tidak ada credential yang di-commit ke Git.
- Application secret dibuat kosong. Isi melalui AWS Console atau CLI setelah deployment pertama.
- HTTPS dan custom domain tidak termasuk secara default; tambahkan ACM dan HTTPS listener jika domain production tersedia.
