variable "name" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "alb_security_group_id" {
  type = string
}
variable "application_security_group_id" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "min_size" {
  type    = number
  default = 1
}
variable "max_size" {
  type    = number
  default = 3
}
variable "desired_capacity" {
  type    = number
  default = 1
}
variable "image_uris" {
  type = map(string)
}
variable "database_host" {
  type = string
}
variable "database_secret_arn" {
  type = string
}
variable "application_secret_arn" {
  type = string
}
variable "redis_host" {
  type = string
}
variable "uploads_bucket_name" {
  type = string
}
variable "uploads_bucket_arn" {
  type = string
}

variable "cicd_artifacts_bucket_arn" {
  type    = string
  default = ""
}
