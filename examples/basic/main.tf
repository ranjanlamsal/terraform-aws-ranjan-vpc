terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../module/vpc"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "basic-example-vpc"
  }

  subnet_config = {
    public_subnet = {
      cidr_block        = "10.0.1.0/24"
      az               = "${var.aws_region}a"
      public           = true
      assign_public_ip = true
    }
    private_subnet = {
      cidr_block = "10.0.2.0/24"
      az         = "${var.aws_region}b"
      allow_nat  = true
    }
  }

  custom_tags = {
    Environment = "example"
    Project     = "basic-vpc-example"
    Example     = "basic"
  }
}