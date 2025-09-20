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
    cidr_block = var.vpc_cidr_block
    name       = "${var.project_name}-vpc"
  }

  subnet_config = {
    # Public subnets for load balancers and bastion hosts
    public_web_1a = {
      cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 1)
      az               = data.aws_availability_zones.available.names[0]
      public           = true
      assign_public_ip = true
    }
    public_web_1b = {
      cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 2)
      az               = data.aws_availability_zones.available.names[1]
      public           = true
      assign_public_ip = true
    }
    public_web_1c = {
      cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 3)
      az               = data.aws_availability_zones.available.names[2]
      public           = true
      assign_public_ip = true
    }

    # Private subnets for application servers (with NAT access)
    private_app_1a = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 10)
      az         = data.aws_availability_zones.available.names[0]
      allow_nat  = true
    }
    private_app_1b = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 11)
      az         = data.aws_availability_zones.available.names[1]
      allow_nat  = true
    }
    private_app_1c = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 12)
      az         = data.aws_availability_zones.available.names[2]
      allow_nat  = true
    }

    # Private subnets for microservices (with NAT access)
    private_services_1a = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 20)
      az         = data.aws_availability_zones.available.names[0]
      allow_nat  = true
    }
    private_services_1b = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 21)
      az         = data.aws_availability_zones.available.names[1]
      allow_nat  = true
    }
    private_services_1c = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 22)
      az         = data.aws_availability_zones.available.names[2]
      allow_nat  = true
    }

    # Database subnets (no internet access)
    database_1a = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 30)
      az         = data.aws_availability_zones.available.names[0]
      public     = false
      allow_nat  = false
    }
    database_1b = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 31)
      az         = data.aws_availability_zones.available.names[1]
      public     = false
      allow_nat  = false
    }
    database_1c = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 32)
      az         = data.aws_availability_zones.available.names[2]
      public     = false
      allow_nat  = false
    }

    # Cache subnets (no internet access)
    cache_1a = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 40)
      az         = data.aws_availability_zones.available.names[0]
      public     = false
      allow_nat  = false
    }
    cache_1b = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 41)
      az         = data.aws_availability_zones.available.names[1]
      public     = false
      allow_nat  = false
    }

    # Management/Operations subnet
    management_1a = {
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 50)
      az         = data.aws_availability_zones.available.names[0]
      allow_nat  = true
    }
  }

  custom_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Example     = "complete"
      ManagedBy   = "terraform"
    }
  )
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}