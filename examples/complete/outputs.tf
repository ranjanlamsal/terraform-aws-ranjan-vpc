# VPC Information
output "vpc_info" {
  description = "Complete VPC information"
  value = {
    id         = module.vpc.vpc_id
    arn        = module.vpc.vpc_arn
    cidr_block = module.vpc.vpc_cidr_block
    default_sg = module.vpc.default_security_group_id
    default_rt = module.vpc.default_route_table_id
  }
}

# Network Infrastructure
output "network_infrastructure" {
  description = "Network infrastructure details"
  value = {
    internet_gateway = {
      id  = module.vpc.internet_gateway_id
      arn = module.vpc.internet_gateway_arn
    }
    nat_gateway = {
      id        = module.vpc.nat_gateway_id
      public_ip = module.vpc.nat_gateway_public_ip
    }
    elastic_ip = {
      id        = module.vpc.elastic_ip_id
      public_ip = module.vpc.elastic_ip_public_ip
    }
    route_tables = {
      public_rt  = module.vpc.public_route_table_id
      private_rt = module.vpc.private_route_table_id
    }
  }
}

# Subnet Groups for Different Tiers
output "subnet_groups" {
  description = "Subnet groups organized by tier and purpose"
  value = {
    public_web = {
      for k, v in module.vpc.public_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = module.vpc.all_subnet_ids[k].cidr_block
      }
      if can(regex("public_web", k))
    }
    
    private_app = {
      for k, v in module.vpc.private_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = module.vpc.all_subnet_ids[k].cidr_block
      }
      if can(regex("private_app", k))
    }
    
    private_services = {
      for k, v in module.vpc.private_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = module.vpc.all_subnet_ids[k].cidr_block
      }
      if can(regex("private_services", k))
    }
    
    database = {
      for k, v in module.vpc.all_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = v.cidr_block
      }
      if can(regex("database", k))
    }
    
    cache = {
      for k, v in module.vpc.all_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = v.cidr_block
      }
      if can(regex("cache", k))
    }
    
    management = {
      for k, v in module.vpc.private_subnet_ids : k => {
        subnet_id  = v.subnet_id
        az         = v.az
        cidr_block = module.vpc.all_subnet_ids[k].cidr_block
      }
      if can(regex("management", k))
    }
  }
}

# Simplified outputs for common use cases
output "load_balancer_subnet_ids" {
  description = "Subnet IDs for Application Load Balancers"
  value = [
    for k, v in module.vpc.public_subnet_ids : v.subnet_id
    if can(regex("public_web", k))
  ]
}

output "application_subnet_ids" {
  description = "Subnet IDs for application servers"
  value = [
    for k, v in module.vpc.private_subnet_ids : v.subnet_id
    if can(regex("private_app", k))
  ]
}

output "database_subnet_ids" {
  description = "Subnet IDs for databases (RDS subnet group)"
  value = [
    for k, v in module.vpc.all_subnet_ids : v.subnet_id
    if can(regex("database", k))
  ]
}

output "cache_subnet_ids" {
  description = "Subnet IDs for cache services (ElastiCache subnet group)"
  value = [
    for k, v in module.vpc.all_subnet_ids : v.subnet_id
    if can(regex("cache", k))
  ]
}

# Availability Zone Information
output "availability_zones" {
  description = "Availability zones used in this deployment"
  value = distinct([
    for k, v in module.vpc.all_subnet_ids : v.az
  ])
}

# CIDR Information for Security Groups
output "vpc_cidr_block" {
  description = "VPC CIDR block for security group rules"
  value = module.vpc.vpc_cidr_block
}

# All subnets summary
output "subnets_summary" {
  description = "Summary of all subnets with their properties"
  value = {
    total_count = length(module.vpc.all_subnet_ids)
    public_count = length([
      for k, v in module.vpc.all_subnet_ids : k
      if contains(keys(module.vpc.public_subnet_ids), k)
    ])
    private_with_nat_count = length([
      for k, v in module.vpc.all_subnet_ids : k
      if contains(keys(module.vpc.private_subnet_ids), k)
    ])
    private_isolated_count = length([
      for k, v in module.vpc.all_subnet_ids : k
      if !contains(keys(module.vpc.public_subnet_ids), k) && 
         !contains(keys(module.vpc.private_subnet_ids), k)
    ])
  }
}