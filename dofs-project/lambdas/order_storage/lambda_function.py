import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("orders")   # Matches the name you created in Terraform

def lambda_handler(event, context):
    print("Storing event:", event)

    table.put_item(Item={
        "order_id": event["order_id"],
        "item": event["item"],
        "quantity": event.get("quantity", 1),
        "status": "PENDING"
    })

    return event
