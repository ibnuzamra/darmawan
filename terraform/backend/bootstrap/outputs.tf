output "s3_bucket_name" {
  description = "S3 bucket name used for Terraform remote state"
  value       = aws_s3_bucket.tf_state.id
}

output "s3_bucket_arn" {
  description = "ARN of S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.tf_state.arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking"
  value       = aws_dynamodb_table.tf_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of DynamoDB table used for state locking"
  value       = aws_dynamodb_table.tf_locks.arn
}
