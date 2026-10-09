variable "name" {
  type = string
}
variable "alert_email" {
  type    = string
  default = ""
}
variable "log_retention_days" {
  type    = number
  default = 30
}
variable "alb_arn_suffix" {
  type = string
}
variable "backend_target_group_arn_suffix" {
  type = string
}
variable "autoscaling_group_names" {
  type = map(string)
}
