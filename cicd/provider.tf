terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
  backend "s3" {
    bucket = "rajasekhar-store-remote-state"
    key    = "jenkins-practice"
    region = "us-east-1"
    dynamodb_table = "rajasekhar-store-remote-locking"
  }
}

#provide authentication here
provider "aws" {
  region = "us-east-1"
}