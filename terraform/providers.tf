terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    // default values. Configuration in backend/env.hcl
    bucket         = "cloudicity-dev-tfstates"
    key            = "cloudicity-mqtt-server/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
      Team        = "IT"
      VPC         = "cloudicity"
    }
  }
}

data "terraform_remote_state" "cloudicity_core" {
  backend = "s3"

  config = {
    bucket = "cloudicity-${var.environment}-tfstates"
    key    = "infra-core/terraform.tfstate"
    region = "eu-west-1"
  }

}
