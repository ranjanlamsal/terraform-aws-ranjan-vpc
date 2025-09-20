# AWS VPC Terraform Module

A comprehensive Terraform module for creating and managing AWS VPC infrastructure with flexible subnet configurations, automatic Internet Gateway and NAT Gateway provisioning.

## Features

- ✅ **Flexible VPC Creation** - Create VPC with custom CIDR blocks and naming
- ✅ **Dynamic Subnet Management** - Support for both public and private subnets with configurable availability zones
- ✅ **Automatic Internet Gateway** - Conditionally creates Internet Gateway when public subnets are defined
- ✅ **NAT Gateway Support** - Automatic NAT Gateway creation for private subnets with internet access
- ✅ **Route Table Management** - Automatic routing configuration for public and private subnets
- ✅ **Comprehensive Validation** - Built-in validation for CIDR blocks, subnet configurations, and logical dependencies
- ✅ **Custom Tagging** - Apply custom tags to all created resources
- ✅ **Rich Outputs** - Comprehensive outputs for all created resources including IDs, ARNs, and networking details

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "your-namespace/vpc/aws"
  version = "~> 1.0"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-production-vpc"
  }

  subnet_config = {
    public_subnet = {
      cidr_block        = "10.0.1.0/24"
      az               = "us-west-2a"
      public           = true
      assign_public_ip = true
    }
    private_subnet = {
      cidr_block = "10.0.2.0/24"
      az         = "us-west-2b"
      allow_nat  = true
    }
  }

  custom_tags = {
    Environment = "production"
    Project     = "my-project"
    Owner       = "devops-team"
  }
}
```

### Multi-AZ Example with Multiple Subnets

```hcl
module "vpc" {
  source = "your-namespace/vpc/aws"
  version = "~> 1.0"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "multi-az-vpc"
  }

  subnet_config = {
    public_subnet_1a = {
      cidr_block        = "10.0.1.0/24"
      az               = "us-west-2a"
      public           = true
      assign_public_ip = true
    }
    public_subnet_1b = {
      cidr_block        = "10.0.2.0/24"
      az               = "us-west-2b"
      public           = true
      assign_public_ip = true
    }
    private_subnet_1a = {
      cidr_block = "10.0.10.0/24"
      az         = "us-west-2a"
      allow_nat  = true
    }
    private_subnet_1b = {
      cidr_block = "10.0.11.0/24"
      az         = "us-west-2b"
      allow_nat  = true
    }
    database_subnet_1a = {
      cidr_block = "10.0.20.0/24"
      az         = "us-west-2a"
      public     = false
      allow_nat  = false
    }
    database_subnet_1b = {
      cidr_block = "10.0.21.0/24"
      az         = "us-west-2b"
      public     = false
      allow_nat  = false
    }
  }

  custom_tags = {
    Environment = "production"
    Project     = "web-application"
    Terraform   = "true"
  }
}
```

### Private-Only VPC Example

```hcl
module "vpc" {
  source = "your-namespace/vpc/aws"
  version = "~> 1.0"

  vpc_config = {
    cidr_block = "172.16.0.0/16"
    name       = "private-vpc"
  }

  subnet_config = {
    private_subnet_1 = {
      cidr_block = "172.16.1.0/24"
      az         = "us-west-2a"
      public     = false
      allow_nat  = false
    }
    private_subnet_2 = {
      cidr_block = "172.16.2.0/24"
      az         = "us-west-2b"
      public     = false
      allow_nat  = false
    }
  }

  custom_tags = {
    Environment = "development"
    Type        = "isolated"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | CIDR and name for the VPC | <pre>object({<br>    cidr_block = string<br>    name       = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_config"></a> [subnet\_config](#input\_subnet\_config) | Configuration for subnets with cidr block and az | <pre>map(object({<br>    cidr_block        = string<br>    az               = string<br>    public           = optional(bool, false)<br>    assign_public_ip = optional(bool, false)<br>    allow_nat        = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |

### Input Validation Rules

- **VPC Name**: Must not be empty
- **CIDR Blocks**: Must be valid CIDR notation for both VPC and subnets
- **Availability Zones**: Must not be empty
- **Subnet Names**: Must not be empty
- **Public IP Assignment**: Private subnets cannot be assigned public IPs
- **NAT Gateway Logic**: Public subnets cannot be routed through NAT Gateway
- **NAT Dependencies**: If NAT Gateway is enabled, at least one public subnet must exist

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
| <a name="output_vpc_arn"></a> [vpc\_arn](#output\_vpc\_arn) | ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | CIDR block of the VPC |
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | ID of the default security group |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | ID of the default route table |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map of public subnet names to their details |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Map of private subnet names to their details |
| <a name="output_all_subnet_ids"></a> [all\_subnet\_ids](#output\_all\_subnet\_ids) | Map of all subnet names to their details |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the Internet Gateway |
| <a name="output_internet_gateway_arn"></a> [internet\_gateway\_arn](#output\_internet\_gateway\_arn) | ARN of the Internet Gateway |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | ID of the NAT Gateway |
| <a name="output_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#output\_nat\_gateway\_public\_ip) | Public IP of the NAT Gateway |
| <a name="output_elastic_ip_id"></a> [elastic\_ip\_id](#output\_elastic\_ip\_id) | ID of the Elastic IP for NAT Gateway |
| <a name="output_elastic_ip_public_ip"></a> [elastic\_ip\_public\_ip](#output\_elastic\_ip\_public\_ip) | Public IP address of the Elastic IP |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | ID of the public route table |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | ID of the private route table |

### Output Format Examples

**Subnet Outputs Format:**
```hcl
# public_subnet_ids, private_subnet_ids, all_subnet_ids
{
  "subnet_name" = {
    subnet_id  = "subnet-12345678"
    az         = "us-west-2a"
    cidr_block = "10.0.1.0/24"  # Only in all_subnet_ids
  }
}
```

## Architecture

This module creates the following AWS resources:

- **VPC** - Virtual Private Cloud with specified CIDR block
- **Subnets** - Public and/or private subnets across specified availability zones
- **Internet Gateway** - Automatically created when public subnets are defined
- **NAT Gateway** - Automatically created when private subnets with `allow_nat = true` are defined
- **Elastic IP** - Associated with NAT Gateway
- **Route Tables** - Separate route tables for public and private subnets
- **Route Table Associations** - Automatic association of subnets with appropriate route tables

### Network Flow

1. **Public Subnets** → Internet Gateway → Internet
2. **Private Subnets (with NAT)** → NAT Gateway → Internet Gateway → Internet
3. **Private Subnets (without NAT)** → No internet access

## Examples

For more detailed examples, check the `examples/` directory:

- `examples/basic/` - Simple VPC with one public and one private subnet
- `examples/multi-az/` - Multi-AZ setup with high availability
- `examples/private-only/` - VPC with only private subnets

## Best Practices

1. **CIDR Planning**: Plan your CIDR blocks carefully to avoid overlaps with other VPCs
2. **Availability Zones**: Distribute subnets across multiple AZs for high availability
3. **Tagging**: Use consistent tagging strategy across all resources
4. **Security**: Place databases and internal services in private subnets
5. **Cost Optimization**: Only enable NAT Gateway when internet access is required for private subnets

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

## Authors

Module managed by [Ranjan Lamsal](https://github.com/ranjanlamsal).

## Support

For questions or issues:
- Create an issue in this repository
- Check existing issues and discussions
- Review the examples for common use cases