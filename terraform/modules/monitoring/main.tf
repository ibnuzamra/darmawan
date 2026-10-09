resource "aws_cloudwatch_log_group" "laravel_app" {
  name              = "/aws/ec2/${var.name}/laravel"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "nginx_access" {
  name              = "/aws/ec2/${var.name}/nginx-access"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "nginx_error" {
  name              = "/aws/ec2/${var.name}/nginx-error"
  retention_in_days = var.log_retention_days
}

resource "aws_sns_topic" "critical_alerts" {
  name = "${var.name}-alerts-critical"
}

resource "aws_sns_topic" "warning_alerts" {
  name = "${var.name}-alerts-warning"
}

resource "aws_sns_topic_subscription" "critical_email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_subscription" "warning_email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.warning_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Critical: ALB Unhealthy Hosts
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts_backend" {
  alarm_name          = "${var.name}-alb-unhealthy-hosts-backend"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Triggers when backend instances fail ALB health check"
  alarm_actions       = [aws_sns_topic.critical_alerts.arn]
  ok_actions          = [aws_sns_topic.critical_alerts.arn]

  dimensions = {
    TargetGroup  = var.backend_target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}

# Critical: ALB HTTP 5XX Error Rate
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.name}-alb-high-5xx-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Triggers when application returns more than 10 5XX responses in 1 minute"
  alarm_actions       = [aws_sns_topic.critical_alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Warning: ALB High Response Time (Latency)
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.name}-alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1.5
  alarm_description   = "Average target response time exceeds 1.5 seconds"
  alarm_actions       = [aws_sns_topic.warning_alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# Warning: High EC2 CPU Utilization across ASG
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_warning" {
  for_each            = var.autoscaling_group_names
  alarm_name          = "${var.name}-asg-${each.key}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Average CPU utilization for ${each.key} ASG exceeds 80%"
  alarm_actions       = [aws_sns_topic.warning_alerts.arn]

  dimensions = {
    AutoScalingGroupName = each.value
  }
}
