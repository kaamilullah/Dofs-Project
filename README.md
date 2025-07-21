# Dofs-Project

Prerequisites
AWS Account with permissions to create and manage IAM, Lambda, API Gateway, SQS, DynamoDB, Step Functions, S3, CodeBuild, and CodePipeline resources.

AWS CLI installed and configured with credentials for an IAM user/service account that can access above resources.

Terraform (v1.6.6 or newer) installed and available on your PATH.

Git for version control and code management.

Python 3.12 for local Lambda packaging if manual zipping is needed.

(Optional) AWS CodeBuild/CodePipeline sample project privileges for automated deployment.

Setup Instructions
1. Clone the Repository
bash
git clone https://github.com/kaamilullah/Dofs-Project.git
cd Dofs-Project
2. Configure Terraform Backend
Update terraform/backend.tf with your own:

S3 bucket for state (bucket = "<your-s3-bucket>")

DynamoDB table for state lock (dynamodb_table = "<your-lock-table>")

Provision those resources if absent (examples in AWS docs).

3. Package Lambda Functions (Manual/First-Time Only)
If CI/CD is not yet set up to zip Lambdas:

bash
cd lambdas/api_handler && zip api_handler.zip lambda_function.py && mv api_handler.zip ../../terraform/modules/lambdas/
cd ../validator && zip validator.zip lambda_function.py && mv validator.zip ../../terraform/modules/lambdas/
cd ../order_storage && zip order_storage.zip lambda_function.py && mv order_storage.zip ../../terraform/modules/lambdas/
cd ../fulfill_order && zip fulfill_order.zip lambda_function.py && mv fulfill_order.zip ../../terraform/modules/lambdas/
cd ../dlq_handler && zip dlq_handler.zip lambda_function.py && mv dlq_handler.zip ../../terraform/modules/lambdas/
4. Deploy Infrastructure Manually (Initial)
bash
cd terraform
terraform init
terraform apply
5. Set Up the CI/CD Pipeline
Ensure buildspec.yml is at the root of the repository.

From terraform/, apply the CI/CD infrastructure:

bash
terraform apply
This deploys:

CodeBuild project (with IAM roles)

Serverless stack (API Gateway, Lambdas, SQS, Step Functions, DynamoDB)

6. Run Your First CI Build
From any environment with AWS CLI configured:

bash
aws codebuild start-build --project-name dofs-ci
Watch build logs via AWS CLI or the CodeBuild Console.

Troubleshooting
Symptom	Solution
buildspec.yml: no such file or directory	Ensure buildspec.yml is committed at the repo root and pushed to the branch being built.
Lambda AccessDeniedException	Double-check Lambda IAM policy for required resource and action (e.g., dynamodb:PutItem).
"Reference to undeclared resource" in Terraform	Use module outputs/variables, not direct cross-module references, for resource sharing.
CodeBuild cannot access repo	Use a public repository, or set up GitHub OAuth/Connections for private repos and update source.
API returns Internal server error	Check CloudWatch logs for stack traces/permissions error in Lambda or Step Function.
DynamoDB not updated with order	Validate that Lambda role has correct PutItem/UpdateItem permissions and uses right table name.
SQS event mapping fails (ReceiveMessage error)	Attach SQS policy to Lambda IAM role with receive/delete/change message visibility permissions.
Quick checks:

Use aws codebuild batch-get-builds to monitor builds.

Use CloudWatch for Lambda and Step Functions logs.

Validate that all environment variables and table names match those defined in Terraform.

Pipeline Explanation
This project utilizes a cloud-native, infrastructure-as-code CI/CD pipeline, built with AWS CodeBuild and managed through Terraform.

Pipeline Stages
Source

All code (Terraform, Lambda, configs) is in this GitHub repository.

Build/Deploy (CodeBuild)

CodeBuild project (dofs-ci) runs on-demand or can be connected to CodePipeline for auto-triggered builds.

buildspec.yml defines all steps:

Downloads and installs Terraform

Optionally creates zipped Lambda deployment packages

Runs terraform init, plan, and apply

Applies code and infrastructure updates as one step

Manual/Automatic Trigger

Start builds with aws codebuild start-build --project-name dofs-ci

(Optionally) Add CodePipeline for GitHub webhook integration for push-to-deploy on each commit.

Live Infrastructure

All infrastructure and Lambda packaging is driven by code.

No manual AWS Console steps are required aside from optional monitoring or CodeBuild/Connections setup for private repos.

Example Workflow
Commit code to GitHub main

Start CodeBuild job (manually or via pipeline trigger)

CodeBuild provisions or updates infrastructure per Terraform and package/deliver Lambda code if you included zipping in buildspec.yml

Monitor build status in AWS Console or via CLI tools

Verify deployment by sending a test request to the API endpoint; confirm updates cascade through the whole stack