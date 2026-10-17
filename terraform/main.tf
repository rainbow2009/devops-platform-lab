terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["081073840758"]
}

variable "environment" {
  type    = string
  default = "uat"
}

variable "github_repo" {
  description = "GitHub repository (owner/name) allowed to assume the CI role via OIDC"
  type        = string
  default     = "rainbow2009/devops-platform-lab"
}

locals {
  name_prefix = "tf-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "demo" {
  bucket = "${local.name_prefix}-ci-demo"
  tags   = local.common_tags
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}