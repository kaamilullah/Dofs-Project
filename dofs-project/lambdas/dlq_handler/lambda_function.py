import json
import boto3

dynamodb = boto3.resource("dynamodb")
failed_orders_table = dynamodb.Table("failed_orders")

def lambda_handler(event, context):
    for record in event["Records"]:
        try:
            order = json.loads(record["body"])
            print("Failed order received from DLQ:", order)

            failed_orders_table.put_item(Item={
                "order_id": order["order_id"],
                "item": order["item"],
                "quantity": order.get("quantity", 1),
                "reason": "Moved to DLQ after max retries"
            })

            print(f"✅ Inserted failed order into failed_orders table: {order['order_id']}")

        except Exception as e:
            print(f"❌ Error processing record: {str(e)}")
