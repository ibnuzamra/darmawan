variable "name" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "github_owner" {
  type = string
}
variable "github_repositories" {
  type = map(string)
}
variable "github_branch" {
  type    = string
  default = "main"
}
variable "autoscaling_group_names" {
  type = map(string)
}

variable "target_group_names" {
  type = map(string)
}

