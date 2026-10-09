Task 3: Monitoring dan Alerting

## Monitoring Aplikasi

### Log Laravel

- Log aplikasi ditulis ke CloudWatch log group di bawah `/aws/ec2/<env-name>/laravel`.
- Instance profile EC2 menyertakan managed policy `CloudWatchAgentServerPolicy` sehingga CloudWatch Agent dapat mengirim log.
- Di production, disarankan `APP_DEBUG=false` sehingga error dicatat di log alih-alih ditampilkan.

### Pelacakan Error

- Log ALB tidak dikumpulkan secara default pada module ini, tetapi health check target group menunjukkan kegagalan backend melalui alarm `UnHealthyHostCount`.
- Untuk pelacakan error yang lebih mendalam, log Laravel dapat diteruskan ke CloudWatch Logs atau tool observability khusus melalui sidecar container atau CloudWatch Agent.

## Monitoring Infrastruktur

### Alarm CloudWatch

| Alarm | Severity | Trigger |
|-------|----------|---------|
| `alb-unhealthy-hosts-backend` | Critical | Target backend gagal health check ALB selama 2 menit berturut-turut. |
| `alb-high-5xx-rate` | Critical | Lebih dari 10 respons HTTP 5XX dalam satu menit. |
| `alb-high-latency` | Warning | Rata-rata target response time melebihi 1.5 detik selama 3 menit. |
| `asg-<component>-cpu-high` | Warning | Rata-rata CPU ASG melebihi 80% selama 6 menit. |

### RDS dan ElastiCache

- RDS Performance Insights diaktifkan untuk visibilitas production terhadap slow query dan beban database.
- ElastiCache Redis memakai transit encryption dan at-rest encryption.
- Metric CloudWatch untuk RDS (`CPUUtilization`, `DatabaseConnections`, `FreeableMemory`) dan ElastiCache (`CPUUtilization`, `EngineCPUUtilization`) dapat ditambahkan jika diperlukan.

## Strategi Alerting

- **Critical alert** dikirim ke SNS topic `critical_alerts`.
- **Warning alert** dikirim ke SNS topic `warning_alerts`.
- Setiap topic dapat memiliki email subscription dengan mengatur `alert_email` di file `*.tfvars`.

### Kanal Notifikasi

| Kanal | Didukung | Cara |
|---------|-----------|-----|
| Email | Ya | `aws_sns_topic_subscription` dengan protokol `email`. |
| Slack | Parsial | Tambahkan subscription SNS-to-Lambda yang memanggil Slack webhook, atau subscribe SNS topic ke Amazon Chatbot. |
| SMS | Ya | Tambahkan `aws_sns_topic_subscription` dengan protokol `sms`. |

## Runbook Operasional

1. **Aplikasi down**
   - Periksa alarm `alb-unhealthy-hosts-backend` dan `alb-high-5xx-rate`.
   - Tinjau CloudWatch log group Laravel untuk stack trace.
   - Verifikasi target ASG memiliki instance healthy dan container Docker sedang berjalan.

2. **Latency tinggi**
   - Periksa RDS Performance Insights untuk slow query.
   - Konfirmasi latency Redis dan jumlah koneksi pada metrik ElastiCache.
   - Scale ASG secara vertikal atau horizontal jika CPU menjadi bottleneck.

3. **Kegagalan koneksi database**
   - Konfirmasi endpoint RDS dan aturan security group.
   - Periksa metrik `DatabaseConnections` dibandingkan batas maksimum instance RDS.
   - Validasi nilai Laravel `.env` atau Secrets Manager.
