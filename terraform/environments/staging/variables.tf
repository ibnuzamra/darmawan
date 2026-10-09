variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}
variable "aws_account_id" {
  type = string
}
variable "environment" {
  type    = string
  default = "staging"
}
variable "name" {
  type    = string
  default = "laravel-staging"
}
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}
variable "ec2_instance_type" {
  type    = string
  default = "t3.small"
}
variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "backend_image_uri" {
  type = string
}
variable "frontend_image_uri" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "github_repositories" {
  type = map(string)
}
variable "alert_email" {
  type    = string
  default = ""
}
