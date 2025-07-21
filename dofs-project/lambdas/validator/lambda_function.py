import json

def lambda_handler(event, context):
    print("Validating event:", event)

    if "order_id" not in event or "item" not in event:
        raise Exception("Validation Failed: Missing required fields")

    return event  # Pass the data to the next state
