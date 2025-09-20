# Multi-AZ VPC Example

This example demonstrates a production-ready multi-tier, multi-AZ VPC setup with:
- 3 Public subnets across 3 availability zones
- 3 Private application subnets with NAT Gateway access
- 3 Database subnets with no internet access
- High availability and fault tolerance design

## Architecture

```
┌───────────────────────────────────────────────────────────────────────────────────────┐
│                                VPC (10.0.0.0/16)                                     │
│                                                                                       │
│   AZ-A (us-west-2a)       AZ-B (us-west-2b)       AZ-C (us-west-2c)                │
│                                                                                       │
│ ┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐             │
│ │  Public Subnet 1A   │ │  Public Subnet 1B   │ │  Public Subnet 1C   │             │
│ │   (10.0.1.0/24)     │ │   (10.0.2.0/24)     │ │   (10.0.3.0/24)     │             │
│ │                     │ │                     │ │                     │             │
│ │ ┌─────────────────┐ │ │                     │ │                     │             │
│ │ │  NAT Gateway    │ │ │                     │ │                     │             │
│ │ │   (with EIP)    │ │ │                     │ │                     │             │
│ │ └─────────────────┘ │ │                     │ │                     │             │
│ └─────────┬───────────┘ └─────────────────────┘ └─────────────────────┘             │
│           │                                                                         │
│ ┌─────────▼───────────────────────────────────────────────────────────────────────┐ │
│ │                         Internet Gateway                                        │ │
│ └─────────┬───────────────────────────────────────────────────────────────────────┘ │
│           │                       │                       │                         │
│ ┌─────────▼───────────┐ ┌─────────▼───────────┐ ┌─────────▼───────────┐             │
│ │ Private App Subnet  │ │ Private App Subnet  │ │ Private App Subnet  │             │
│ │   (10.0.10.0/24)    │ │   (10.0.11.0/24)    │ │   (10.0.12.0/24)    │             │
│ │                     │ │                     │ │                     │             │
│ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │             │
│ │ │  App Servers    │ │ │ │  App Servers    │ │ │ │  App Servers    │ │             │
│ │ └─────────────────┘ │ │ └─────────────────┘ │ │ └─────────────────┘ │             │
│ └─────────────────────┘ └─────────────────────┘ └─────────────────────┘             │
│           │                       │                       │                         │
│ ┌─────────▼───────────┐ ┌─────────▼───────────┐ ┌─────────▼───────────┐             │
│ │ Database Subnet     │ │ Database Subnet     │ │ Database Subnet     │             │
│ │   (10.0.20.0/24)    │ │   (10.0.21.0/24)    │ │   (10.0.22.0/24)    │             │
│ │                     │ │                     │ │                     │             │
│ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │ │ ┌─────────────────┐ │             │
│ │ │   Databases     │ │ │ │   Databases     │ │ │ │   Databases     │ │             │
│ │ │  (No Internet)  │ │ │ │  (No Internet)  │ │ │ │  (No Internet)  │ │             │
│ │ └─────────────────┘ │ │ └─────────────────┘ │ │ └─────────────────┘ │             │
│ └─────────────────────┘ └─────────────────────┘ └─────────────────────┘             │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

## Design Principles

### High Availability
- Resources spread across 3 availability zones
- Database subnets in each AZ for RDS Multi-AZ deployments
- Application tier distributed for load balancing

### Security Layers
- **Public Tier**: Load balancers, bastion hosts
- **Private App Tier**: Application servers with outbound internet via NAT
- **Database Tier**: Isolated databases with no internet access

### Network Segmentation
- Clear separation between tiers
- Database subnet group for RDS
- Application subnet group for Auto Scaling Groups

## Usage

```bash
# Clone and navigate
git clone <repository-url>
cd examples/multi-az

# Initialize and apply
terraform init
terraform plan
terraform apply

# Clean up
terraform destroy
```

## Use Cases

This architecture is perfect for:

1. **Production Web Applications**
   - ALB in public subnets
   - EC2/ECS in private app subnets
   - RDS in database subnets

2. **Microservices Architecture**
   - API Gateway in public subnets
   - Services in private app subnets
   - Shared databases in database subnets

3. **Enterprise Applications**
   - Bastion hosts in public subnets
   - Application servers in private subnets
   - Database clusters in database subnets

## AWS Services Integration

### Load Balancing
```hcl
# Application Load Balancer subnet group
subnet_ids = [
  module.vpc.public_subnet_ids["public_subnet_1a"].subnet_id,
  module.vpc.public_subnet_ids["public_subnet_1b"].subnet_id,
  module.vpc.public_subnet_ids["public_subnet_1c"].subnet_id
]
```

### Auto Scaling Groups
```hcl
# ASG across private app subnets
vpc_zone_identifier = [
  module.vpc.private_subnet_ids["private_app_1a"].subnet_id,
  module.vpc.private_subnet_ids["private_app_1b"].subnet_id,
  module.vpc.private_subnet_ids["private_app_1c"].subnet_id
]
```

### RDS Subnet Group
```hcl
# Database subnet group
subnet_ids = [
  module.vpc.all_subnet_ids["database_subnet_1a"].subnet_id,
  module.vpc.all_subnet_ids["database_subnet_1b"].subnet_id,
  module.vpc.all_subnet_ids["database_subnet_1c"].subnet_id
]
```

## Expected Costs

Monthly costs (assuming 24/7 operation):
- NAT Gateway: ~$45/month
- Elastic IP: ~$3.65/month
- Data transfer: Variable based on usage
- **Total base cost**: ~$50/month

## Customization Examples

### Different Region
```bash
terraform apply -var="aws_region=eu-west-1"
```

### Custom CIDR Blocks
Modify the CIDR blocks in `main.tf` to fit your network design.

### Additional Subnets
Add more subnets by extending the `subnet_config` block.

## Best Practices Implemented

1. **Subnet Sizing**: /24 subnets provide 251 usable IPs each
2. **AZ Distribution**: Even distribution across availability zones
3. **Security**: Database tier completely isolated from internet
4. **Scalability**: Room for growth with proper CIDR planning
5. **Cost Optimization**: Single NAT Gateway (can be enhanced to one per AZ for higher availability)

## Next Steps

After deployment, consider:
1. Adding security groups for each tier
2. Setting up VPC Flow Logs
3. Implementing Network ACLs for additional security
4. Adding VPC endpoints for AWS services
5. Setting up monitoring and alerting

## Production Considerations

For production use, consider:
- **Multiple NAT Gateways**: One per AZ for higher availability
- **VPC Endpoints**: Reduce NAT Gateway costs for AWS service calls
- **Transit Gateway**: For multi-VPC connectivity
- **AWS PrivateLink**: For secure service connectivity