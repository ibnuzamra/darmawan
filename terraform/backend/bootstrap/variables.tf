variable "aws_region" {
  description = "AWS region for Terraform backend infrastructure"
  type        = string
  default     = "ap-southeast-1"
}

variable "state_bucket_name" {
  description = "Unique S3 bucket name for storing Terraform state files"
  type        = string
  default     = "dat-laravel-tfstate-ap-southeast-1"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "dat-laravel-tflocks"
}
