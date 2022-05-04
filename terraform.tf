terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "polygon-v3-dev-terraform"
    region = "us-east-1"
  }
}

provider "aws" {
  //profile = "default"
  region  = "us-east-1"
}
