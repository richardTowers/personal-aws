terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }

  backend "s3" {
    bucket = "personal-aws-tfstate"
    key    = "deliberatepractice-dev-zone"
    region = "eu-west-1"
  }

  required_version = ">= 1.4.1"
}

provider "aws" {
  region  = "eu-west-1"

  default_tags {
    tags = {
      managed_by          = "terraform"
      managing_repository = "github.com/richardtowers/personal-aws"
      managing_deployment = "deliberatepractice-dev-zone"
    }
  }
}

