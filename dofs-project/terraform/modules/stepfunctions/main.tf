resource "aws_sfn_state_machine" "order_state_machine" {
  name     = "order_state_machine"
  role_arn = aws_iam_role.sfn_execution_role.arn

  definition = jsonencode({
    StartAt = "ValidateOrder",
    States = {
      "ValidateOrder" = {
        Type = "Task",
        Resource = var.validator_lambda_arn,
        Next = "StoreOrder"
      },
      "StoreOrder" = {
        Type = "Task",
        Resource = var.order_storage_lambda_arn,
        Next = "SendToSQS"
      },
      "SendToSQS" = {
        Type = "Task",
        Resource = "arn:aws:states:::sqs:sendMessage",
        Parameters = {
          QueueUrl = var.order_queue_url,
          "MessageBody.$" = "$"
        },
        End = true
      }
    }
  })
}

resource "aws_iam_role" "sfn_execution_role" {
  name = "sfn_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "states.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_policy" {
  name = "sfn_policy"
  role = aws_iam_role.sfn_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "sqs:SendMessage"
        ],
        Resource = "*"
      }
    ]
  })
}
