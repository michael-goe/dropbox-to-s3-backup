#
# SNS
#
resource "aws_sns_topic" "backup_notifications" {
  name = "${var.prefix}-notifications"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:${var.prefix}-notifications",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"arn:aws:s3:::${var.s3_bucket_name}"}
        }
    }]
}
POLICY
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.backups_dropbox.id

  topic {
    topic_arn = aws_sns_topic.backup_notifications.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:LifecycleTransition"]
  }

  depends_on = [aws_sns_topic.backup_notifications]
}

resource "aws_sns_topic_subscription" "notify_by_mail" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.email_address
}