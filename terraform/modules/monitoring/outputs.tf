output "critical_alert_topic_arn" { value = aws_sns_topic.critical_alerts.arn }
output "warning_alert_topic_arn" { value = aws_sns_topic.warning_alerts.arn }
