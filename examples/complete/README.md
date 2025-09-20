# Complete VPC Example

This comprehensive example demonstrates all features of the VPC module with a production-ready, enterprise-grade setup. It includes multiple tiers, comprehensive tagging, and showcases best practices for large-scale applications.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                        VPC (10.0.0.0/16)                                                   │
│                                                                                                             │
│          AZ-A (us-west-2a)              AZ-B (us-west-2b)              AZ-C (us-west-2c)                   │
│                                                                                                             │
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐ ┌─────────────────────────────┐             │
│ │      Public Web Tier        │ │      Public Web Tier        │ │      Public Web Tier        │             │
│ │     (10.0.1.0/24)           │ │     (10.0.2.0/24)           │ │     (10.0.3.0/24)           │             │
│ │                             │ │                             │ │                             │             │
│ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │             │
│ │ │   ALB / Bastion Host    │ │ │ │   ALB / Bastion Host    │ │ │ │   ALB / Bastion Host    │ │             │
│ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │             │
│ └─────────────┬───────────────┘ └─────────────────────────────┘ └─────────────────────────────┘             │
│               │                                               │                                             │
│ ┌─────────────▼───────────────┐ ┌─────────────────────────────┐ ┌─────────────────────────────┐             │
│ │  Internet Gateway           │ │                             │ │                             │             │
│ └─────────────┬───────────────┘ └─────────────────────────────┘ └─────────────────────────────┘             │
│               │                               │                               │                             │
│ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐             │
│ │   Private App Tier          │ │   Private App Tier          │ │   Private App Tier          │             │
│ │    (10.0.10.0/24)           │ │    (10.0.11.0/24)           │ │    (10.0.12.0/24)           │             │
│ │                             │ │                             │ │                             │             │
│ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │             │
│ │ │   Application Servers   │ │ │ │   Application Servers   │ │ │ │   Application Servers   │ │             │
│ │ │      (EC2/ECS)          │ │ │ │      (EC2/ECS)          │ │ │ │      (EC2/ECS)          │ │             │
│ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │             │
│ └─────────────┬───────────────┘ └─────────────┬───────────────┘ └─────────────┬───────────────┘             │
│               │                               │                               │                             │
│ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐             │
│ │  Private Services Tier      │ │  Private Services Tier      │ │  Private Services Tier      │             │
│ │    (10.0.20.0/24)           │ │    (10.0.21.0/24)           │ │    (10.0.22.0/24)           │             │
│ │                             │ │                             │ │                             │             │
│ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │             │
│ │ │     Microservices       │ │ │ │     Microservices       │ │ │ │     Microservices       │ │             │
│ │ │    (API Gateway/ECS)    │ │ │ │    (API Gateway/ECS)    │ │ │ │    (API Gateway/ECS)    │ │             │
│ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │             │
│ └─────────────┬───────────────┘ └─────────────┬───────────────┘ └─────────────┬───────────────┘             │
│               │                               │                               │                             │
│ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐ ┌─────────────▼───────────────┐             │
│ │     Database Tier           │ │     Database Tier           │ │     Database Tier           │             │
│ │    (10.0.30.0/24)           │ │    (10.0.31.0/24)           │ │    (10.0.32.0/24)           │             │
│ │                             │ │                             │ │                             │             │
│ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │             │
│ │ │   RDS Multi-AZ          │ │ │ │   RDS Read Replicas     │ │ │ │   RDS Read Replicas     │ │             │
│ │ │   (No Internet)         │ │ │ │   (No Internet)         │ │ │ │   (No Internet)         │ │             │
│ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │             │
│ └─────────────────────────────┘ └─────────────────────────────┘ └─────────────────────────────┘             │
│                                                                                                             │
│ ┌─────────────────────────────┐ ┌─────────────────────────────┐                                             │
│ │      Cache Tier             │ │      Cache Tier             │                                             │
│ │    (10.0.40.0/24)           │ │    (10.0.41.0/24)           │                                             │
│ │                             │ │                             │                                             │
│ │ ┌─────────────────────────┐ │ │ ┌─────────────────────────┐ │                                             │
│ │ │   ElastiCache Redis     │ │ │ │   ElastiCache Redis     │ │                                             │
│ │ │   (No Internet)         │ │ │ │   (No Internet)         │ │                                             │
│ │ └─────────────────────────┘ │ │ └─────────────────────────┘ │                                             │
│ └─────────────────────────────┘ └─────────────────────────────┘                                             │
│                                                                                                             │
│ ┌─────────────────────────────┐                                                                             │
│ │    Management Tier          │    NAT Gateway in first public subnet                                      │
│ │    (10.0.50.0/24)           │    provides internet access for:                                           │
│ │                             │    • Private App Tier                                                      │
│ │ ┌─────────────────────────┐ │    • Private Services Tier                                                 │
│ │ │   Monitoring Tools      │ │    • Management Tier                                                       │
│ │ │   Jenkins/Ansible       │ │                                                                             │
│ │ └─────────────────────────┘ │                                                                             │
│ └─────────────────────────────┘                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Features Demonstrated

### 🏗️ **Multi-Tier Architecture**
- **Public Web Tier** - Load balancers, bastion hosts
- **Private App Tier** - Application servers with internet access via NAT
- **Private Services Tier** - Microservices and internal APIs
- **Database Tier** - Completely isolated database subnets
- **Cache Tier** - Redis/Memcached subnets
- **Management Tier** - Monitoring and deployment tools

### 🌐 **Network Design**
- **3 Availability Zones** for high availability
- **Automatic CIDR calculation** using `cidrsubnet()` function
- **Internet Gateway** for public subnets
- **Single NAT Gateway** for cost optimization (can be enhanced to multi-AZ)
- **Proper routing** for each tier

### 🏷️ **Advanced Tagging**
- **Environment-based tagging**
- **Cost center tracking**
- **Compliance and ownership tags**
- **Customizable tag inheritance**

### 🔧 **Configuration Flexibility**
- **Variable validation** for inputs
- **Dynamic AZ selection**
- **Comprehensive outputs** for integration
- **Example tfvars** file

## Usage

### Quick Start

```bash
# Clone and navigate
git clone <repository-url>
cd examples/complete

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy
terraform init
terraform plan
terraform apply
```

### Customization Options

#### 1. Environment-Specific Deployment

```bash
# Development environment
terraform apply -var="environment=development" -var="project_name=myapp-dev"

# Staging environment  
terraform apply -var="environment=staging" -var="project_name=myapp-staging"

# Production environment
terraform apply -var="environment=production" -var="project_name=myapp-prod"
```

#### 2. Different CIDR Ranges

```bash
# Using different CIDR block
terraform apply -var="vpc_cidr_block=172.16.0.0/16"
```

#### 3. Custom Region

```bash
# Deploy to different region
terraform apply -var="aws_region=eu-west-1"
```

## Integration Examples

### Application Load Balancer

```hcl
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  
  subnets = module.vpc.load_balancer_subnet_ids
  
  enable_deletion_protection = true
  
  tags = var.common_tags
}
```

### Auto Scaling Group

```hcl
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = module.vpc.application_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  
  min_size = 2
  max_size = 10
  
  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-server"
    propagate_at_launch = true
  }
}
```

### RDS Subnet Group

```hcl
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = module.vpc.database_subnet_ids
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-database"
  
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.medium"
  
  allocated_storage = 100
  storage_encrypted = true
  
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  
  multi_az = true  # Uses multiple AZs from our subnet group
  
  tags = var.common_tags
}
```

### ElastiCache Subnet Group

```hcl
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = module.vpc.cache_subnet_ids
  
  tags = var.common_tags
}

resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "Redis cluster for ${var.project_name}"
  
  port                       = 6379
  parameter_group_name       = "default.redis7"
  node_type                  = "cache.t3.micro"
  
  num_cache_clusters         = 2
  
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [aws_security_group.cache.id]
  
  tags = var.common_tags
}
```

## Security Groups Example

```hcl
# Web tier security group
resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  vpc_id      = module.vpc.vpc_info.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-web-sg"
    Tier = "web"
  })
}

# Application tier security group
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-app-"
  vpc_id      = module.vpc.vpc_info.id
  
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-app-sg"
    Tier = "application"
  })
}

# Database tier security group
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-db-"
  vpc_id      = module.vpc.vpc_info.id
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-sg"
    Tier = "database"
  })
}
```

## Expected Costs

Base infrastructure costs (monthly):
- **NAT Gateway**: ~$45
- **Elastic IP**: ~$3.65
- **Data Transfer**: Variable (typically $10-50 depending on usage)
- **Total Base Cost**: ~$60-100/month

Additional service costs depend on what you deploy:
- **RDS Multi-AZ**: $50-500+ depending on instance size
- **ElastiCache**: $15-200+ depending on instance size
- **ALB**: $20-30/month + data processing fees
- **EC2 Instances**: Variable based on size and count

## Production Readiness Checklist

### Security
- [ ] Enable VPC Flow Logs
- [ ] Configure Network ACLs
- [ ] Set up security groups with least privilege
- [ ] Enable AWS Config for compliance
- [ ] Set up GuardDuty for threat detection

### Monitoring
- [ ] CloudWatch dashboards for VPC metrics
- [ ] VPC Flow Log analysis
- [ ] Network performance monitoring
- [ ] Cost monitoring and alerting

### Backup & DR
- [ ] Cross-region VPC peering if needed
- [ ] Database backup strategy
- [ ] Document recovery procedures
- [ ] Test disaster recovery procedures

### Operations
- [ ] Set up bastion host or Session Manager
- [ ] Configure centralized logging
- [ ] Implement Infrastructure as Code practices
- [ ] Set up automated deployments

## Scaling Considerations

### High Availability Enhancement
```hcl
# Multiple NAT Gateways (one per AZ)
# This would require modifying the module or creating additional NAT gateways

# VPC Endpoints for cost optimization
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_info.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  
  route_table_ids = [
    module.vpc.network_infrastructure.route_tables.private_rt
  ]
}
```

### Multi-Region Setup
- Use this module in multiple regions
- Set up cross-region VPC peering
- Implement Route 53 for DNS failover
- Consider AWS Transit Gateway for complex routing

## Best Practices Implemented

1. **Network Segmentation**: Clear separation between tiers
2. **High Availability**: Multi-AZ deployment
3. **Security**: Private subnets for sensitive workloads
4. **Cost Optimization**: Single NAT Gateway
5. **Scalability**: Room for growth with /24 subnets
6. **Maintainability**: Comprehensive tagging and outputs
7. **Flexibility**: Parameterized configuration

## Troubleshooting

### Common Issues

1. **AZ Availability**: Some regions have fewer than 3 AZs
   ```bash
   # Check available AZs
   aws ec2 describe-availability-zones --region us-west-2
   ```

2. **CIDR Conflicts**: Ensure CIDR doesn't overlap with existing VPCs
   ```bash
   # List existing VPCs
   aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]' --output table
   ```

3. **Quota Limits**: Check VPC and subnet limits
   ```bash
   # Check VPC limits
   aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE
   ```

This complete example provides a solid foundation for enterprise-grade applications with room for customization and growth.