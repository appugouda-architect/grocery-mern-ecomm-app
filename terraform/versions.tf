terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in S3 — create this bucket + DynamoDB table manually before first init.
  # Run: aws s3 mb s3://grocery-app-terraform-state --region us-east-1
  #      aws dynamodb create-table --table-name grocery-app-terraform-locks \
  #        --attribute-definitions AttributeName=LockID,AttributeType=S \
  #        --key-schema AttributeName=LockID,KeyType=HASH \
  #        --billing-mode PAY_PER_REQUEST --region us-east-1
  backend "s3" {
    bucket         = "grocery-app-terraform-state"
    key            = "grocery-app/terraform.tfstate"  # override per env with -backend-config
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "grocery-app-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "grocery-mern-app"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
