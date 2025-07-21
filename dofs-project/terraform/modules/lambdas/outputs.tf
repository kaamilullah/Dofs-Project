output "api_handler_invoke_arn" {
  value = aws_lambda_function.api_handler.invoke_arn
}

output "api_handler_function_name" {
  value = aws_lambda_function.api_handler.function_name
}

output "validator_lambda_arn" {
  value = aws_lambda_function.validator.arn
}

output "order_storage_lambda_arn" {
  value = aws_lambda_function.order_storage.arn
}


output "dlq_queue_arn_passed" {
  value = var.dlq_queue_arn
}
