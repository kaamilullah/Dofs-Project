output "order_queue_url" {
  value = aws_sqs_queue.order_queue.id
}

output "order_queue_arn" {
  value = aws_sqs_queue.order_queue.arn
}

output "order_dlq_arn" {
  value = aws_sqs_queue.order_dlq.arn
}
