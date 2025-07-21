resource "aws_sqs_queue" "order_dlq" {
  name                      = "order_dlq"
  message_retention_seconds = 1209600 # 14 days (max)
}

resource "aws_sqs_queue" "order_queue" {
  name                      = "order_queue"
  visibility_timeout_seconds = 30
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq.arn
    maxReceiveCount     = 3
  })
}
