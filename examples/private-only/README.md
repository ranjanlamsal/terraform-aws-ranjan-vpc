# Private-Only VPC Example

This example demonstrates a fully isolated VPC with no internet connectivity:
- All subnets are private (no Internet Gateway)
- No NAT Gateway (no outbound internet access)
- Suitable for highly secure environments
- Access only via VPN, Direct Connect, or VPC Peering

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          Private VPC (172.16.0.0/16)                           │
│                              (No Internet Access)                              │
│                                                                                 │
│      AZ-A (us-west-2a)                     AZ-B (us-west-2b)                   │
│                                                                                 │
│ ┌─────────────────────────────┐      ┌─────────────────────────────┐           │
│ │    Internal App Subnet      │      │    Internal App Subnet      │           │
│ │     (172.16.1.0/24)         │      │     (172.16.2.0/24)         │           │
│ │                             │      │                             │           │
│ │ ┌─────────────────────────┐ │      │ ┌─────────────────────────┐ │           │
│ │ │   Application Servers   │ │      │ │   Application Servers   │ │           │
│ │ │    (No Internet)        │ │      │ │    (No Internet)        │ │           │
│ │ └─────────────────────────┘ │      │ └─────────────────────────┘ │           │
│ └─────────────────────────────┘      └─────────────────────────────┘           │
│                                                                                 │
│ ┌─────────────────────────────┐      ┌─────────────────────────────┐           │
│ │     Database Subnet         │      │     Database Subnet         │           │
│ │     (172.16.10.0/24)        │      │     (172.16.11.0/24)        │           │
│ │                             │      │                             │           │
│ │ ┌─────────────────────────┐ │      │ ┌─────────────────────────┐ │           │
│ │ │      Databases          │ │      │ │      Databases          │ │           │
│ │ │   (Fully Isolated)      │ │      │ │   (Fully Isolated)      │ │           │
│ │ └─────────────────────────┘ │      │ └─────────────────────────┘ │           │
│ └─────────────────────────────┘      └─────────────────────────────┘           │
│                                                                                 │
│ ┌─────────────────────────────┐                                                │
│ │    Management Subnet        │      External Access Options:                  │
│ │     (172.16.20.0/24)        │      • VPN Gateway                            │
│ │                             │      • AWS Direct Connect                     │
│ │ ┌─────────────────────────┐ │      • VPC Peering                           │
│ │ │   Management Tools      │ │      • AWS Systems Manager                    │
│ │ │     (Monitoring)        │ │      • VPC Endpoints                         │
│ │ └─────────────────────────┘ │                                               │
│ └─────────────────────────────┘                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Use Cases

This architecture is ideal for:

### High-Security Environments
- Financial services applications
- Healthcare systems (HIPAA compliance)
- Government and defense systems
- Critical infrastructure

### Internal Applications
- Employee directories and HR systems
- Internal APIs and microservices
- Development and testing environments
- Data processing pipelines

### Compliance Requirements
- Air-gapped environments
- SOC 2 Type II compliance
- PCI DSS compliance
- GDPR data sovereignty

## Access Methods

Since there's no internet connectivity, access options include:

### 1. VPN Gateway
```hcl
resource "aws_vpn_gateway" "main" {
  vpc_id = module.vpc.vpc_id
  
  tags = {
    Name = "private-vpc-vpn-gateway"
  }
}
```

### 2. AWS Direct Connect
- Dedicated network connection from on-premises
- Higher bandwidth and lower latency
- More consistent network performance

### 3. VPC Peering
```hcl
resource "aws_vpc_peering_connection" "main" {
  vpc_id      = module.vpc.vpc_id
  peer_vpc_id = var.management_vpc_id
  auto_accept = true
}
```

### 4. AWS Systems Manager Session Manager
- Access EC2 instances without SSH/RDP
- No inbound ports or bastion hosts required
- Requires VPC endpoints

### 5. VPC Endpoints
```hcl
# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  
  subnet_ids = [
    module.vpc.all_subnet_ids["internal_app_1a"].subnet_id,
    module.vpc.all_subnet_ids["internal_app_1b"].subnet_id
  ]
}
```

## Usage

```bash
# Deploy the private VPC
terraform init
terraform plan
terraform apply

# Note: No internet access means:
# - No outbound internet from instances
# - No inbound internet access
# - Package updates require VPC endpoints or proxy
```

## Adding VPC Endpoints

For AWS service access without internet:

```hcl
# Common VPC endpoints needed
locals {
  vpc_endpoints = {
    s3 = {
      service_name = "com.amazonaws.${var.aws_region}.s3"
      type         = "Gateway"
    }
    ec2 = {
      service_name = "com.amazonaws.${var.aws_region}.ec2"
      type         = "Interface"
    }
    ssm = {
      service_name = "com.amazonaws.${var.aws_region}.ssm"
      type         = "Interface"
    }
    ssmmessages = {
      service_name = "com.amazonaws.${var.aws_region}.ssmmessages"
      type         = "Interface"
    }
    ec2messages = {
      service_name = "com.amazonaws.${var.aws_region}.ec2messages"
      type         = "Interface"
    }
  }
}
```

## Security Considerations

### Network ACLs
```hcl
resource "aws_network_acl" "private" {
  vpc_id = module.vpc.vpc_id

  # Allow internal VPC communication only
  ingress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = module.vpc.vpc_cidr_block
    action     = "allow"
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = module.vpc.vpc_cidr_block
    action     = "allow"
  }
}
```

### Security Groups
```hcl
resource "aws_security_group" "internal_only" {
  name_prefix = "internal-only-"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic only within VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}
```

## Cost Benefits

This setup has minimal ongoing costs:
- ✅ No NAT Gateway charges (~$45/month savings)
- ✅ No Elastic IP charges (~$3.65/month savings)
- ✅ No data transfer charges through NAT
- ⚠️ VPC endpoints have hourly charges ($0.01/hour per endpoint)

## Monitoring and Logging

### VPC Flow Logs
```hcl
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}
```

### CloudWatch Insights Queries
```sql
# Analyze internal traffic patterns
fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol, action
| filter srcaddr like /^172\.16\./
| stats count() by srcaddr, dstaddr
| sort count desc
```

## Limitations

- No internet access for software updates
- Requires VPC endpoints for AWS service access
- Higher complexity for troubleshooting
- Additional cost for VPN/Direct Connect setup

## Migration Considerations

When migrating from internet-connected environments:
1. Audit all external dependencies
2. Set up VPC endpoints for AWS services
3. Configure software repositories via proxy or endpoints
4. Test connectivity thoroughly before migration

## Next Steps

After deployment:
1. Set up VPN or Direct Connect
2. Configure VPC endpoints for required AWS services
3. Implement comprehensive monitoring
4. Set up backup and disaster recovery
5. Document access procedures for your team