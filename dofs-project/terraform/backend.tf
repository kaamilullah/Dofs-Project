terraform {
  backend "s3" {
    bucket         = "my-terraform-state-kamil"
    key            = "dofs/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}