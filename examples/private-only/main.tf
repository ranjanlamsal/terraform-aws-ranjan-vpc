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
    cidr_block = "172.16.0.0/16"
    name       = "private-only-vpc"
  }

  subnet_config = {
    # Private subnets for internal applications
    internal_app_1a = {
      cidr_block = "172.16.1.0/24"
      az         = "${var.aws_region}a"
      public     = false
      allow_nat  = false
    }
    internal_app_1b = {
      cidr_block = "172.16.2.0/24"
      az         = "${var.aws_region}b"
      public     = false
      allow_nat  = false
    }
    
    # Database subnets
    database_1a = {
      cidr_block = "172.16.10.0/24"
      az         = "${var.aws_region}a"
      public     = false
      allow_nat  = false
    }
    database_1b = {
      cidr_block = "172.16.11.0/24"
      az         = "${var.aws_region}b"
      public     = false
      allow_nat  = false
    }
    
    # Management/Operations subnet
    management_1a = {
      cidr_block = "172.16.20.0/24"
      az         = "${var.aws_region}a"
      public     = false
      allow_nat  = false
    }
  }

  custom_tags = {
    Environment = "secure"
    Project     = "private-only-example"
    NetworkType = "isolated"
    Example     = "private-only"
    Connectivity = "vpn-only"
  }
}