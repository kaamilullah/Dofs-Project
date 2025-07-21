output "orders_table_name" {
  value = module.dynamodb.orders_table_name
}

output "failed_orders_table_name" {
  value = module.dynamodb.failed_orders_table_name
}
