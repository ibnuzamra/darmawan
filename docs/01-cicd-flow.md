Task 1: Arsitektur dan Alur CI/CD

## Layout Repository

```
live-project/
├── laravel-backend/           # Repository GitHub backend (Laravel API)
│   ├── buildspec.yml
│   ├── appspec.yml
│   ├── scripts/
│   │   ├── stop-container.sh
│   │   ├── deploy-container.sh
│   │   └── validate-service.sh
│   └── Dockerfile
└── laravel-frontend/          # Repository GitHub frontend (Vue.js SPA / Laravel Blade)
      # salin ketiga file deployment yang sama
```

> Script deployment, `buildspec.yml`, dan `appspec.yml` sama untuk kedua repository sehingga dapat ditempatkan di `ci/` lalu disalin ke masing-masing repo sebelum deployment.

## Alur Pipeline

```
GitHub Push ──► CodeStar Connection ──► CodePipeline
                                           │
                    ┌─────────────────────┴─────────────────────┐
                    ▼                                           ▼
            Pipeline Backend                            Pipeline Frontend
                    │                                           │
                    ▼                                           ▼
            CodeBuild (Docker)                        CodeBuild (Docker)
                    │                                           │
                    ▼                                           ▼
            Push ke ECR                                     Push ke ECR
                    │                                           │
                    ▼                                           ▼
            CodeDeploy ──► ASG Backend              CodeDeploy ──► ASG Frontend
```

## Apa yang Terjadi pada Setiap Push

1. **Tahap Source**
   - CodeStar Source Connection mendeteksi push ke branch yang dikonfigurasi di repository backend atau frontend.
   - CodePipeline mengunduh source code ke bucket artefak S3.

2. **Tahap Build**
   - CodeBuild menjalankan `buildspec.yml`.
   - Ia login ke ECR, membangun Docker image, memberi tag dengan commit hash dan `latest`, lalu push kedua tag ke repository ECR yang sesuai.
   - Artefak `image-detail.json` dibuat untuk CodeDeploy.

3. **Tahap Deploy**
   - CodeDeploy mengunduh artefak ke setiap instance dalam Auto Scaling Group target.
   - `ApplicationStop`: container `laravel-<component>` yang sedang berjalan dihapus.
   - `AfterInstall`: `deploy-container.sh` membaca `image-detail.json`, pull image baru, lalu menjalankan container pada port 80.
   - `ValidateService`: `validate-service.sh` mengakses `http://localhost/` untuk memastikan container sehat.

## Pemisahan Komponen

- **ASG Backend** diakses melalui listener rule ALB `/api/*`.
- **ASG Frontend** menerima seluruh traffic lainnya melalui default action ALB listener.
- Setiap repo memiliki CodePipeline, CodeBuild project, CodeDeploy application, dan deployment group sendiri.

## Catatan Keamanan

- Image scanning aktif pada setiap push ke ECR.
- CodeBuild memiliki akses read-only ke Secrets Manager hanya untuk nilai yang dibutuhkan saat build time.
- CodePipeline memakai CodeStar Connection ARN; connection harus di-authorize melalui AWS Console sebelum pipeline dapat mengambil kode dari GitHub.
