output "vpc_id" {
  description = "ID of the VPC"
  value = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value = aws_vpc.main.cidr_block
}

output "default_security_group_id" {
  description = "ID of the default security group"
  value = aws_vpc.main.default_security_group_id
}

output "default_route_table_id" {
  description = "ID of the default route table"
  value = aws_vpc.main.default_route_table_id
}

locals {
  public_subnet_outputs = {
    for key, config in local.public_subnet_config: key => {
        subnet_id = aws_subnet.main[key].id
        az = aws_subnet.main[key].availability_zone
    }
  }

  private_subnet_outputs = {
    for key, config in local.private_subnets_config: key => {
        subnet_id = aws_subnet.main[key].id
        az = aws_subnet.main[key].availability_zone
    }
  }

  all_subnet_outputs = {
    for key, subnet in aws_subnet.main: key => {
        subnet_id = subnet.id
        az = subnet.availability_zone
        cidr_block = subnet.cidr_block
    }
  }
}

output "public_subnet_ids" {
  description = "Map of public subnet names to their details"
  value = local.public_subnet_outputs
}

output "private_subnet_ids" {
  description = "Map of private subnet names to their details"
  value = local.private_subnet_outputs
}

output "all_subnet_ids" {
  description = "Map of all subnet names to their details"
  value = local.all_subnet_outputs
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].id : null
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].arn : null
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value = length(aws_nat_gateway.main) > 0 ? aws_nat_gateway.main[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value = length(aws_nat_gateway.main) > 0 ? aws_nat_gateway.main[0].public_ip : null
}

output "elastic_ip_id" {
  description = "ID of the Elastic IP for NAT Gateway"
  value = length(aws_eip.main) > 0 ? aws_eip.main[0].id : null
}

output "elastic_ip_public_ip" {
  description = "Public IP address of the Elastic IP"
  value = length(aws_eip.main) > 0 ? aws_eip.main[0].public_ip : null
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value = length(aws_route_table.main) > 0 ? aws_route_table.main[0].id : null
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value = length(aws_route_table.private-rt) > 0 ? aws_route_table.private-rt[0].id : null
}
