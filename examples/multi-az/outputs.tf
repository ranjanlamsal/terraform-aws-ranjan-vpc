output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Public subnet outputs
output "public_subnet_ids" {
  description = "Map of public subnet names to their IDs"
  value = {
    for k, v in module.vpc.public_subnet_ids : k => v.subnet_id
  }
}

# Private application subnet outputs
output "private_app_subnet_ids" {
  description = "Map of private application subnet IDs"
  value = {
    for k, v in module.vpc.private_subnet_ids : k => v.subnet_id
    if can(regex("private_app", k))
  }
}

# Database subnet outputs
output "database_subnet_ids" {
  description = "Map of database subnet IDs"
  value = {
    for k, v in module.vpc.all_subnet_ids : k => v.subnet_id
    if can(regex("database", k))
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vpc.nat_gateway_public_ip
}

# Availability zones for reference
output "availability_zones" {
  description = "List of availability zones used"
  value = [
    "${var.aws_region}a",
    "${var.aws_region}b", 
    "${var.aws_region}c"
  ]
}

# Subnet groups for easy consumption
output "subnet_groups" {
  description = "Subnet groups organized by tier"
  value = {
    public = {
      for k, v in module.vpc.public_subnet_ids : k => {
        subnet_id = v.subnet_id
        az        = v.az
      }
    }
    private_app = {
      for k, v in module.vpc.private_subnet_ids : k => {
        subnet_id = v.subnet_id
        az        = v.az
      }
      if can(regex("private_app", k))
    }
    database = {
      for k, v in module.vpc.all_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = v.cidr_block
      }
      if can(regex("database", k))
    }
  }
}