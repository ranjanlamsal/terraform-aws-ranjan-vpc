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
    name       = "multi-az-vpc"
  }

  subnet_config = {
    # Public subnets across multiple AZs
    public_subnet_1a = {
      cidr_block        = "10.0.1.0/24"
      az               = "${var.aws_region}a"
      public           = true
      assign_public_ip = true
    }
    public_subnet_1b = {
      cidr_block        = "10.0.2.0/24"
      az               = "${var.aws_region}b"
      public           = true
      assign_public_ip = true
    }
    public_subnet_1c = {
      cidr_block        = "10.0.3.0/24"
      az               = "${var.aws_region}c"
      public           = true
      assign_public_ip = true
    }

    # Private subnets for application tier
    private_app_1a = {
      cidr_block = "10.0.10.0/24"
      az         = "${var.aws_region}a"
      allow_nat  = true
    }
    private_app_1b = {
      cidr_block = "10.0.11.0/24"
      az         = "${var.aws_region}b"
      allow_nat  = true
    }
    private_app_1c = {
      cidr_block = "10.0.12.0/24"
      az         = "${var.aws_region}c"
      allow_nat  = true
    }

    # Database subnets (no internet access)
    database_subnet_1a = {
      cidr_block = "10.0.20.0/24"
      az         = "${var.aws_region}a"
      public     = false
      allow_nat  = false
    }
    database_subnet_1b = {
      cidr_block = "10.0.21.0/24"
      az         = "${var.aws_region}b"
      public     = false
      allow_nat  = false
    }
    database_subnet_1c = {
      cidr_block = "10.0.22.0/24"
      az         = "${var.aws_region}c"
      public     = false
      allow_nat  = false
    }
  }

  custom_tags = {
    Environment   = "production"
    Project       = "multi-az-example"
    Architecture  = "multi-tier"
    Example       = "multi-az"
    HighAvailability = "true"
  }
}