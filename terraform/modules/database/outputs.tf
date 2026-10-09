output "rds_endpoint" { value = aws_db_instance.this.address }
output "rds_secret_arn" { value = aws_db_instance.this.master_user_secret[0].secret_arn }
output "redis_endpoint" { value = aws_elasticache_replication_group.this.primary_endpoint_address }
