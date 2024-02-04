# REMOTE STATE CONFIG FOR AWS S3
terraform {
  backend "s3" {
    bucket         = "umuts-tf-state"  # Replace with your S3 bucket name
    key            = "assignment/terraform.tfstate"  # Replace with your state file path
    region         = "eu-west-1"  # Replace with your S3 bucket region
    # dynamodb_table = "my-lock-table"  # Replace with your DynamoDB table name for state locking -optional but recommended-
    encrypt        = true
  }
}