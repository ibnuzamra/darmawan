output "uploads_bucket_name" { value = aws_s3_bucket.uploads.id }
output "uploads_bucket_arn" { value = aws_s3_bucket.uploads.arn }
output "application_secret_arn" { value = aws_secretsmanager_secret.app.arn }
