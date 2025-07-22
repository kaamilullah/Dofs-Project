# 🚀 Distributed Order Fulfillment System (DOFS) - Serverless & CI/CD on AWS

This project demonstrates a production-ready **event-driven, serverless architecture** using AWS services and **Terraform**. It includes a fully automated **CI/CD pipeline** using AWS CodeBuild (optionally CodePipeline) for streamlined deployments.

---

## ✅ Prerequisites

Before you begin, ensure you have the following:

- 🧾 **AWS Account** with permissions for:
  - IAM, Lambda, API Gateway, SQS, DynamoDB, Step Functions, S3, CodeBuild, and CodePipeline.
- 🔐 **AWS CLI** installed & configured with access credentials.
- 🌍 **Terraform v1.6.6+** installed and available in your `PATH`.
- 🧪 **Git** for version control and collaboration.
- 🐍 **Python 3.12** (used for Lambda packaging if needed).
- 🔧 (Optional) **CodeBuild/CodePipeline permissions** for CI/CD automation.

---

## 🛠️ Setup Instructions

### 1. 📥 Clone the Repository

```bash
git clone https://github.com/kaamilullah/Dofs-Project.git
cd Dofs-Project
```

---

### 2. ⚙️ Configure Terraform Backend

Edit `terraform/backend.tf` and provide:

```hcl
bucket         = "<your-s3-bucket-name>"        # For remote state storage
dynamodb_table = "<your-dynamodb-table-name>"   # For state locking
```

> 🪣 Ensure your S3 bucket and DynamoDB table exist. Refer to [AWS Docs](https://docs.aws.amazon.com/) to create them if needed.

---

### 3. 📦 Package Lambda Functions (Manual — First Time Only)

> 📝 Only needed if CI/CD is **not yet set up** to zip the Lambda files automatically.

```bash
cd lambdas/api_handler
zip api_handler.zip lambda_function.py
mv api_handler.zip ../../terraform/modules/lambdas/

cd ../validator
zip validator.zip lambda_function.py
mv validator.zip ../../terraform/modules/lambdas/

cd ../order_storage
zip order_storage.zip lambda_function.py
mv order_storage.zip ../../terraform/modules/lambdas/

cd ../fulfill_order
zip fulfill_order.zip lambda_function.py
mv fulfill_order.zip ../../terraform/modules/lambdas/

cd ../dlq_handler
zip dlq_handler.zip lambda_function.py
mv dlq_handler.zip ../../terraform/modules/lambdas/
```

---

### 4. 🚀 Deploy Infrastructure Manually (Initial)

> This step sets up all your AWS resources using Terraform.

```bash
cd terraform
terraform init
terraform apply
```

☑️ This will provision:
- API Gateway
- Lambda Functions
- DynamoDB Table
- SQS Queue
- Step Functions State Machine
- IAM Roles and Permissions

---

### 5. ⚙️ Set Up the CI/CD Pipeline

Make sure `buildspec.yml` is present at the **root** of your repository (same level as `README.md`).

Then, from inside the `terraform/` directory, apply the CI/CD resources:

```bash
cd terraform
terraform apply
```

☑️ This will deploy:

- 📦 **AWS CodeBuild** project (`dofs-ci`)
- 🏗️ Your complete **serverless infrastructure**, if not already provisioned
- 🛡️ All required IAM roles for CodeBuild and Lambda execution

---

### 6. 🔁 Run Your First CI Build

Once the infrastructure is set up, start your first CodeBuild job using:

```bash
aws codebuild start-build --project-name dofs-ci
```

📺 You can monitor the build:

- In the **AWS CodeBuild Console**, or
- Using the CLI:

```bash
aws codebuild batch-get-builds --ids <build-id>
```

> 🛠️ Replace `<build-id>` with the ID returned from `start-build`.

---

## 📊 Pipeline Architecture

This project uses an **AWS-native CI/CD** pipeline, with **Infrastructure as Code (IaC)** using Terraform.

---

### 🧾 Source

- All infrastructure code, Lambda functions, and configuration files live in this **GitHub repository**.

---

### 🔨 Build & Deploy (CodeBuild)

- CodeBuild project (`dofs-ci`) is triggered manually or via webhook.
- Steps are defined in `buildspec.yml`:
  - 📥 Downloads and installs Terraform
  - 📦 Optionally packages Lambda deployment files
  - ⚙️ Runs `terraform init`, `terraform plan`, and `terraform apply`
  - 🔄 Applies code and infra updates as a single, automated step

---

### ⚙️ Trigger Options

- 🖐️ **Manual** trigger using `aws codebuild start-build`
- 🔗 **Automatic** trigger via CodePipeline (optional), integrated with GitHub push events

---

## 🧰 Troubleshooting & FAQs

| 🧩 **Symptom**                                 | ✅ **Solution** |
|-----------------------------------------------|-----------------|
| `buildspec.yml: no such file or directory`    | Ensure `buildspec.yml` is committed at the repo root and pushed to the correct branch. |
| `Lambda AccessDeniedException`                | Check the Lambda IAM role — it must include required permissions (e.g., `dynamodb:PutItem`, `sqs:SendMessage`). |
| `Reference to undeclared resource` in Terraform| Use **module outputs or variables**, not direct cross-module references. |
| CodeBuild cannot access repo                  | Ensure the repo is public or configure **GitHub connection** in AWS. |
| API returns `Internal Server Error`           | Review **CloudWatch logs** for your Lambda or Step Function for tracebacks. |
| DynamoDB not updated                          | Confirm the correct table name and IAM permissions (e.g., `PutItem`). |
| SQS event mapping fails (`ReceiveMessage` error)| Attach SQS permissions (`ReceiveMessage`, `DeleteMessage`, etc.) to the Lambda's IAM role. |

---

🛠️ Quick Checks:

- 🔍 Use `aws codebuild batch-get-builds` to monitor builds.
- 📊 Use **CloudWatch Logs** to debug Lambda and Step Function behavior.
- ✅ Validate that all environment variables, names, and ARNs match exactly with what’s defined in Terraform.

---

## 🧪 Example Workflow

A typical development and deployment cycle looks like this:

1. ✅ **Commit** your code to the `main` branch on GitHub  
2. 🔁 **Trigger** a build:
   - Manually via `aws codebuild start-build`, or
   - Automatically via GitHub push (if CodePipeline is configured)
3. ⚙️ **CodeBuild**:
   - Packages Lambda code (if enabled)
   - Runs `terraform apply` to update infrastructure
4. 📡 **Verify deployment**:
   - Send a request to the API Gateway endpoint
   - Monitor logs in CloudWatch
   - Confirm order flows through Step Function → SQS → Lambda → DynamoDB

---

## ✅ Final Notes

- 💯 Everything in this project is built using **Terraform** — no manual setup is needed in the AWS Console (except optional GitHub connections or monitoring).
- 📦 Lambda packaging, infrastructure provisioning, and CI/CD are all **fully automated**.
- 🔄 Changes to the codebase are **reflected immediately** in the AWS environment through each build.
- 🧹 The project structure is **modular and clean**, with isolated responsibilities:
  - `lambdas/` → Function logic  
  - `terraform/modules/` → Reusable IaC components  
  - `buildspec.yml` → CI/CD build steps
- ☁️ This design follows **best practices** for serverless architecture, CI/CD, and IaC in a real-world environment.
- ✅ Make a commit, push it, and your infrastructure will handle the rest.

---
