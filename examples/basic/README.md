# Basic VPC Example

This example demonstrates the most basic usage of the VPC module with:
- One public subnet with Internet Gateway
- One private subnet with NAT Gateway
- Automatic routing configuration

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                       │
│                                                             │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │   Public Subnet     │    │    Private Subnet           │ │
│  │   (10.0.1.0/24)     │    │    (10.0.2.0/24)           │ │
│  │   us-west-2a        │    │    us-west-2b               │ │
│  │                     │    │                             │ │
│  │  ┌───────────────┐  │    │  ┌───────────────────────┐  │ │
│  │  │ NAT Gateway   │  │    │  │    Private Resources  │  │ │
│  │  │ (with EIP)    │  │    │  │                       │  │ │
│  │  └───────────────┘  │    │  └───────────────────────┘  │ │
│  └─────────┬───────────┘    └─────────┬───────────────────┘ │
│            │                          │                     │
│  ┌─────────▼───────────┐              │                     │
│  │ Internet Gateway    │              │                     │
│  └─────────┬───────────┘              │                     │
└────────────┼──────────────────────────┼─────────────────────┘
             │                          │
             ▼                          ▼
         Internet                   NAT Gateway
                                       │
                                       ▼
                                   Internet
```

## Usage

To run this example:

```bash
# Clone the repository
git clone <repository-url>
cd examples/basic

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Customization

You can customize this example by:

1. **Change the region**: Modify the `aws_region` variable
2. **Adjust CIDR blocks**: Update the CIDR blocks in `main.tf`
3. **Add custom tags**: Extend the `custom_tags` block
4. **Change availability zones**: Modify the AZ assignments

### Example with different region:

```bash
terraform apply -var="aws_region=eu-west-1"
```

## What gets created

- 1 VPC with CIDR 10.0.0.0/16
- 1 Public subnet (10.0.1.0/24) in AZ `a`
- 1 Private subnet (10.0.2.0/24) in AZ `b`
- 1 Internet Gateway
- 1 NAT Gateway with Elastic IP
- 1 Public Route Table (routes to IGW)
- 1 Private Route Table (routes to NAT)
- Route table associations

## Expected Costs

This example will incur costs for:
- NAT Gateway: ~$45/month (if running 24/7)
- Elastic IP: ~$3.65/month (when not attached to running instance)
- Data transfer charges through NAT Gateway

## Testing Connectivity

After deployment, you can test connectivity by:

1. **Launch an EC2 instance in the public subnet** - Should have internet access
2. **Launch an EC2 instance in the private subnet** - Should have outbound internet access via NAT Gateway
3. **Try SSH from public to private instance** - Should work if security groups allow it

## Clean Up

Always remember to clean up resources when done testing:

```bash
terraform destroy
```

This prevents ongoing charges for the NAT Gateway and other resources.