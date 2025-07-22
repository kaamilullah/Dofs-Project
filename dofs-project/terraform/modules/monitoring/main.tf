resource "aws_cloudwatch_log_group" "api_handler_logs" {
  name              = "/aws/lambda/api_handler"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "api_handler_errors" {
  alarm_name          = "ApiHandlerLambdaHighErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if the function errors are more than 1 in a minute."
  dimensions = {
    FunctionName = "api_handler"
  }
}
