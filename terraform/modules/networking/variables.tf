variable "name" {
  description = "Resource name prefix"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "application_port" {
  description = "Application container port"
  type        = number
  default     = 80
}
