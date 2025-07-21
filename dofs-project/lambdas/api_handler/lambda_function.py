import json
import boto3

client = boto3.client("stepfunctions")

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))

    state_machine_arn = "arn:aws:states:us-east-1:880111214601:stateMachine:order_state_machine"

    try:
        response = client.start_execution(
            stateMachineArn=state_machine_arn,
            input=json.dumps(body)
        )

        return {
            "statusCode": 202,
            "body": json.dumps({
                "message": "Order received and being processed",
                "executionArn": response["executionArn"]
            })
        }

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
