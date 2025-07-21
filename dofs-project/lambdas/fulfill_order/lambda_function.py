import json
import random
import boto3

dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table("orders")

def lambda_handler(event, context):
    for record in event['Records']:
        print("Received message:", json.dumps(record))

        try:
            order = json.loads(record['body'])
            order_id = order['order_id']

            # 70% success simulation
            if random.random() <= 0.7:
                status = "FULFILLED"
            else:
                raise Exception("Simulated fulfillment failure")

            # Update DynamoDB order item
            orders_table.update_item(
                Key={"order_id": order_id},
                UpdateExpression="SET #s = :status",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":status": status}
            )

            print(f"Order {order_id} updated with status: {status}")

        except Exception as e:
            print("Error fulfilling order:", str(e))
            raise e  # Let Lambda/SQS retry logic handle this
