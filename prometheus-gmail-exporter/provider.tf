terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.67"
    }
  }

  backend "s3" {
    bucket = "personal-aws-tfstate"
    key    = "prometheus-gmail-exporter"
    region = "eu-west-1"
  }

  required_version = ">= 1.0.11"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"

  default_tags {
    tags = {
      managed_by          = "terraform"
      managing_repository = "github.com/richardtowers/personal-aws"
      managing_deployment = "prometheus-gmail-exporter"
    }
  }
}

