output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = module.vpc.default_security_group_id
}

# All subnets are private in this example
output "all_subnet_ids" {
  description = "Map of all subnet names to their details"
  value = {
    for k, v in module.vpc.all_subnet_ids : k => {
      subnet_id  = v.subnet_id
      az         = v.az
      cidr_block = v.cidr_block
    }
  }
}

# Grouped by purpose
output "application_subnets" {
  description = "Application subnet details"
  value = {
    for k, v in module.vpc.all_subnet_ids : k => {
      subnet_id  = v.subnet_id
      az         = v.az
      cidr_block = v.cidr_block
    }
    if can(regex("internal_app", k))
  }
}

output "database_subnets" {
  description = "Database subnet details"
  value = {
    for k, v in module.vpc.all_subnet_ids : k => {
      subnet_id  = v.subnet_id
      az         = v.az
      cidr_block = v.cidr_block
    }
    if can(regex("database", k))
  }
}

output "management_subnets" {
  description = "Management subnet details"
  value = {
    for k, v in module.vpc.all_subnet_ids : k => {
      subnet_id  = v.subnet_id
      az         = v.az
      cidr_block = v.cidr_block
    }
    if can(regex("management", k))
  }
}

# Confirm no internet-facing resources
output "internet_gateway_id" {
  description = "ID of the Internet Gateway (should be null)"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (should be null)"
  value       = module.vpc.nat_gateway_id
}

# Availability zones for reference
output "availability_zones" {
  description = "List of availability zones used"
  value = distinct([
    for k, v in module.vpc.all_subnet_ids : v.az
  ])
}