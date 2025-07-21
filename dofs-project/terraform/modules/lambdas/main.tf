resource "aws_iam_role" "lambda_exec_role" {
  name = "api_handler_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_stepfn_policy" {
  name = "lambda_stepfn_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "states:StartExecution"
        ],
        Resource = "*"  # Replace this with the specific Step Function ARN later
      }
    ]
  })
}


resource "aws_lambda_function" "api_handler" {
  function_name = "api_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename          = "${path.module}/api_handler.zip"
  source_code_hash  = filebase64sha256("${path.module}/api_handler.zip")

  environment {
    variables = {
      STAGE = "dev"
    }
  }
}

resource "aws_lambda_function" "validator" {
  function_name = "validator"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename          = "${path.module}/validator.zip"
  source_code_hash  = filebase64sha256("${path.module}/validator.zip")
}

resource "aws_lambda_function" "order_storage" {
  function_name = "order_storage"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename          = "${path.module}/order_storage.zip"
  source_code_hash  = filebase64sha256("${path.module}/order_storage.zip")
}


resource "aws_iam_role_policy" "lambda_dynamo_orders_policy" {
  name = "lambda_dynamo_orders_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:880111214601:table/orders"
      }
    ]
  })
}


resource "aws_lambda_function" "fulfill_order" {
  function_name = "fulfill_order"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = "${path.module}/fulfill_order.zip"
  source_code_hash = filebase64sha256("${path.module}/fulfill_order.zip")

  environment {
    variables = {
      TABLE_NAME = "orders"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.fulfill_order.arn
  batch_size       = 1
}


resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda_sqs_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = "arn:aws:sqs:us-east-1:880111214601:order_queue"
      }
    ]
  })
}


resource "aws_lambda_function" "dlq_handler" {
  function_name = "dlq_handler"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = "${path.module}/dlq_handler.zip"
  source_code_hash = filebase64sha256("${path.module}/dlq_handler.zip")
}

resource "aws_lambda_event_source_mapping" "dlq_sqs_trigger" {
  event_source_arn = var.dlq_queue_arn
  function_name    = aws_lambda_function.dlq_handler.arn
  batch_size       = 1
}


resource "aws_iam_role_policy" "lambda_dynamo_failed_orders_policy" {
  name = "lambda_dynamo_failed_orders_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [ "dynamodb:PutItem" ],
        Resource = "arn:aws:dynamodb:us-east-1:880111214601:table/failed_orders"
      }
    ]
  })
}


resource "aws_iam_role_policy" "lambda_dlq_sqs_policy" {
  name = "lambda_dlq_sqs_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ],
        Resource = var.dlq_queue_arn
      }
    ]
  })
}
