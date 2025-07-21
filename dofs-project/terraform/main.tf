provider "aws" {
  region = "us-east-1"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "sqs" {
  source = "./modules/sqs"
}

module "lambdas" {
  source         = "./modules/lambdas"
  sqs_queue_arn  = module.sqs.order_queue_arn
  dlq_queue_arn  = module.sqs.order_dlq_arn
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_invoke_arn    = module.lambdas.api_handler_invoke_arn
  lambda_function_name = module.lambdas.api_handler_function_name
}

module "stepfunctions" {
  source                   = "./modules/stepfunctions"
  validator_lambda_arn     = module.lambdas.validator_lambda_arn
  order_storage_lambda_arn = module.lambdas.order_storage_lambda_arn
  order_queue_url          = module.sqs.order_queue_url
}

module "cicd" {
  source = "./cicd"
}
