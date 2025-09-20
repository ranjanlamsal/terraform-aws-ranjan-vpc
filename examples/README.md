# VPC Module Examples

This directory contains comprehensive examples demonstrating different use cases and configurations of the AWS VPC Terraform module.

## Available Examples

### 🚀 [Basic](./basic/)
**Simple VPC setup for beginners**
- 1 Public subnet with Internet Gateway
- 1 Private subnet with NAT Gateway  
- Basic configuration demonstrating core features
- **Cost**: ~$50/month
- **Use Case**: Development environments, simple applications

### 🏢 [Multi-AZ](./multi-az/)
**Production-ready high availability setup**
- 3 Public subnets across 3 availability zones
- 3 Private application subnets with NAT access
- 3 Database subnets (isolated)
- **Cost**: ~$50/month
- **Use Case**: Production web applications, microservices

### 🔒 [Private-Only](./private-only/)
**Fully isolated VPC with no internet connectivity**
- All private subnets (no Internet Gateway)
- No NAT Gateway (no outbound internet)
- Multiple subnet types for different workloads
- **Cost**: ~$0/month (VPC only)
- **Use Case**: High-security environments, compliance requirements

### 🎯 [Complete](./complete/)
**Enterprise-grade setup showcasing all features**
- Multi-tier architecture (Web, App, Services, Database, Cache)
- Advanced tagging and configuration
- Production best practices
- Comprehensive integration examples
- **Cost**: ~$60-100/month
- **Use Case**: Enterprise applications, complex architectures

## Quick Start

Choose the example that best fits your needs:

```bash
# Clone the repository
git clone <repository-url>

# Navigate to your chosen example
cd examples/basic  # or multi-az, private-only, complete

# Initialize and apply
terraform init
terraform plan
terraform apply

# Clean up when done
terraform destroy
```

## Example Comparison

| Feature | Basic | Multi-AZ | Private-Only | Complete |
|---------|-------|----------|--------------|----------|
| **Availability Zones** | 2 | 3 | 2 | 3 |
| **Public Subnets** | 1 | 3 | 0 | 3 |
| **Private Subnets (with NAT)** | 1 | 3 | 0 | 6 |
| **Private Subnets (isolated)** | 0 | 3 | 5 | 3 |
| **Internet Gateway** | ✅ | ✅ | ❌ | ✅ |
| **NAT Gateway** | ✅ | ✅ | ❌ | ✅ |
| **Custom Tags** | Basic | Standard | Advanced | Enterprise |
| **Complexity** | Low | Medium | Medium | High |
| **Monthly Cost** | ~$50 | ~$50 | ~$0 | ~$60-100 |

## Architecture Patterns

### 🌐 Internet-Connected (Basic, Multi-AZ, Complete)
```
Internet → IGW → Public Subnets → NAT Gateway → Private Subnets
```
- Public resources accessible from internet
- Private resources have outbound internet access
- Suitable for web applications, APIs

### 🔐 Air-Gapped (Private-Only)
```
VPN/DirectConnect → Private Subnets (No Internet Access)
```
- No internet connectivity
- Access via VPN, Direct Connect, or VPC Peering
- Suitable for compliance, security-critical applications

### 🏗️ Multi-Tier (Complete)
```
Internet → ALB (Public) → App Servers (Private+NAT) → Database (Private)
```
- Clear separation between tiers
- Progressive security layers
- Suitable for enterprise applications

## Usage Patterns by Use Case

### 🚀 **Getting Started / Learning**
Start with → **Basic Example**
- Simple to understand
- Demonstrates core concepts
- Quick to deploy and test

### 🏢 **Production Web Applications**
Use → **Multi-AZ Example**
- High availability across zones
- Separate public/private tiers
- Database isolation

### 🔒 **Security-First Environments**
Use → **Private-Only Example**
- No internet exposure
- Compliance-ready
- VPN/DirectConnect required

### 🎯 **Enterprise Applications**
Use → **Complete Example**
- Multiple application tiers
- Advanced configuration
- Production best practices

## Cost Optimization Tips

### Reduce Costs
1. **Remove NAT Gateway** for private-only workloads
2. **Use VPC Endpoints** instead of NAT for AWS services
3. **Single NAT Gateway** across multiple AZs (trade-off: availability)
4. **Right-size subnets** to avoid wasted IP addresses

### Increase Availability (Higher Cost)
1. **Multiple NAT Gateways** (one per AZ)
2. **Cross-region setup** for disaster recovery
3. **Additional monitoring** and logging services

## Security Best Practices

All examples follow security best practices:

### Network Security
- Private subnets for sensitive workloads
- Security groups with least privilege
- Network ACLs for additional protection
- VPC Flow Logs for monitoring

### Access Control
- No direct internet access to databases
- Bastion hosts or Session Manager for admin access
- IAM roles for service authentication
- Encryption in transit and at rest

### Monitoring
- CloudWatch metrics and alarms
- VPC Flow Log analysis
- Security monitoring with GuardDuty
- Cost monitoring and alerting

## Customization Guide

### Modify CIDR Blocks
```hcl
# Change the VPC CIDR
vpc_cidr_block = "172.16.0.0/16"  # Instead of 10.0.0.0/16

# Subnet CIDRs are automatically calculated
```

### Change Regions
```bash
terraform apply -var="aws_region=eu-west-1"
```

### Add Custom Tags
```hcl
custom_tags = {
  Environment    = "production"
  Team          = "platform"
  CostCenter    = "engineering"
  Compliance    = "sox"
}
```

### Scale Subnet Sizes
```hcl
# Use /23 for larger subnets (502 IPs)
cidr_block = cidrsubnet(var.vpc_cidr_block, 7, 1)

# Use /25 for smaller subnets (126 IPs)  
cidr_block = cidrsubnet(var.vpc_cidr_block, 9, 1)
```

## Integration Examples

Each example includes integration patterns for common AWS services:

- **Application Load Balancer** setup
- **Auto Scaling Group** configuration
- **RDS subnet groups** for databases
- **ElastiCache subnet groups** for caching
- **Security group** examples
- **VPC endpoints** for AWS services

## Troubleshooting

Common issues and solutions:

### Deployment Failures
1. **Check AWS credentials** and permissions
2. **Verify region availability** of required AZs
3. **Ensure CIDR blocks** don't conflict with existing VPCs
4. **Check service quotas** for VPCs and subnets

### Connectivity Issues
1. **Verify security groups** allow required traffic
2. **Check route tables** for proper routing
3. **Confirm NAT Gateway** is running and associated
4. **Test with simple resources** (EC2 instances)

### Cost Issues
1. **Monitor NAT Gateway** data transfer costs
2. **Review Elastic IP** usage and attachment
3. **Check for idle resources** in expensive subnets
4. **Consider VPC endpoints** for AWS service calls

## Next Steps

After trying these examples:

1. **Adapt to your needs** - Modify CIDR, regions, tags
2. **Add security layers** - Security groups, NACLs, WAF
3. **Implement monitoring** - CloudWatch, Flow Logs, GuardDuty
4. **Set up CI/CD** - Automated deployments with Terraform
5. **Scale up** - Multi-region, Transit Gateway, advanced networking

## Contributing

Found an issue or want to add an example?

1. Fork this repository
2. Create a new example or fix existing ones
3. Test thoroughly in multiple regions
4. Submit a pull request with clear documentation
5. Include cost estimates and use case descriptions

## Support

- 📖 Check the main [README](../README.md) for module documentation
- 🐛 Report issues in the repository issue tracker  
- 💡 Request new examples or features
- 📧 Contact the maintainers for enterprise support

Each example is production-ready and follows AWS best practices. Choose the one that fits your requirements and customize as needed!