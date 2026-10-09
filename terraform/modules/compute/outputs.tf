output "backend_target_group_name" { value = aws_lb_target_group.backend.name }
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "alb_arn_suffix" { value = aws_lb.this.arn_suffix }
output "backend_target_group_arn_suffix" { value = aws_lb_target_group.backend.arn_suffix }
output "frontend_target_group_arn_suffix" { value = aws_lb_target_group.frontend.arn_suffix }
output "target_group_names" {
  value = {
    backend  = aws_lb_target_group.backend.name
    frontend = aws_lb_target_group.frontend.name
  }
}

output "autoscaling_group_names" {
  value = { for key, group in aws_autoscaling_group.app : key => group.name }
}
