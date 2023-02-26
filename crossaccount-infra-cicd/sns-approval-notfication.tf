resource "aws_sns_topic" "approval_notifications" {
  name = "approval-notifications"

  tags = {
    Environment = var.environment
  }
}

output "approval_notification_arn" {
  value = aws_sns_topic.approval_notifications.arn
}
