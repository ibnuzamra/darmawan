variable "name" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {
  type = string
}
variable "engine_version" {
  type    = string
  default = "8.0"
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "database_name" {
  type    = string
  default = "laravel"
}
variable "database_username" {
  type    = string
  default = "laravel_admin"
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "redis_node_type" {
  type    = string
  default = "cache.t3.micro"
}
variable "backup_retention_period" {
  type    = number
  default = 7
}
variable "deletion_protection" {
  type    = bool
  default = false
}
variable "skip_final_snapshot" {
  type    = bool
  default = true
}
