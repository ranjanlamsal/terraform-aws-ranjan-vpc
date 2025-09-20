# Testing VPC Module Examples

This guide explains how to test and validate that all examples are working correctly before publishing to the Terraform Registry.

## 🧪 **Quick Test All Examples**

Run the automated test script:

```bash
# From the examples directory
./test-examples.sh
```

This script will:
- Initialize each example
- Validate Terraform syntax
- Create a dry-run plan
- Report results for all examples

## 🔍 **Manual Testing Methods**

### 1. **Syntax and Configuration Validation**

Test each example individually:

```bash
# Test basic example
cd examples/basic
terraform init
terraform validate
terraform plan

# Test multi-az example  
cd ../multi-az
terraform init
terraform validate
terraform plan

# Test private-only example
cd ../private-only
terraform init
terraform validate
terraform plan

# Test complete example
cd ../complete
terraform init
terraform validate
terraform plan
```

### 2. **Actual Deployment Testing** (Optional)

⚠️ **Warning**: This will create real AWS resources and incur costs!

```bash
# Deploy basic example (costs ~$50/month)
cd examples/basic
terraform init
terraform plan
terraform apply
# Test connectivity, resources
terraform destroy

# Deploy other examples similarly
```

### 3. **Resource Validation Tests**

After deployment, verify resources are created correctly:

```bash
# Check VPC
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_info | jq -r '.id')

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_info | jq -r '.id')"

# Check internet gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$(terraform output -raw vpc_info | jq -r '.id')"

# Check NAT gateway (if applicable)
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$(terraform output -raw vpc_info | jq -r '.id')"
```

## ✅ **Expected Test Results**

### **All Examples Should Pass:**

1. **terraform init** ✅
   - Downloads AWS provider
   - Initializes module
   - No errors

2. **terraform validate** ✅
   - Syntax validation passes
   - Variable validation passes
   - Resource configuration valid

3. **terraform plan** ✅
   - Creates execution plan
   - Shows resources to be created
   - No errors or warnings

### **Sample Output:**

```
Plan: X to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + network_infrastructure = {
      + elastic_ip       = { /* ... */ }
      + internet_gateway = { /* ... */ }
      + nat_gateway      = { /* ... */ }
      + route_tables     = { /* ... */ }
    }
  + subnets = { /* ... */ }
  + vpc_info = { /* ... */ }
```

## 🐛 **Common Issues and Solutions**

### **Issue: Module source path errors**
```
Error: Module not installed
```
**Solution**: Ensure source path is `../../module/vpc` in all examples

### **Issue: Provider version conflicts**
```
Error: Unsupported Terraform Core version
```
**Solution**: Update Terraform version to >= 1.0

### **Issue: AWS credentials not configured**
```
Error: No valid credential sources
```
**Solution**: Configure AWS credentials:
```bash
aws configure
# OR
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### **Issue: Region doesn't have enough AZs**
```
Error: InvalidParameterValue: Availability zone us-west-1c doesn't exist
```
**Solution**: Use a region with 3+ AZs or modify examples to use 2 AZs

### **Issue: CIDR conflicts**
```
Error: InvalidVpc.Range: The CIDR '10.0.0.0/16' conflicts with another subnet
```
**Solution**: Change VPC CIDR blocks in examples if you have existing VPCs

## 🏃‍♂️ **Performance Testing**

### **Module Load Time**
```bash
time terraform init
# Should complete in < 30 seconds
```

### **Plan Generation Time**
```bash
time terraform plan
# Should complete in < 60 seconds
```

### **Resource Creation Time** (if deploying)
```bash
time terraform apply
# Basic: ~5-10 minutes
# Multi-AZ: ~5-10 minutes  
# Complete: ~10-15 minutes
```

## 🔐 **Security Testing**

### **Check for Hardcoded Secrets**
```bash
# Search for potential secrets in examples
grep -r -i "secret\|password\|key" examples/ --exclude-dir=.terraform
# Should return no results
```

### **Validate Security Group Rules**
```bash
# After deployment, check security groups
aws ec2 describe-security-groups --group-ids $(terraform output -json | jq -r '.vpc_info.value.default_security_group_id')
```

### **Check for Public Resources in Private Subnets**
- Private subnets should not have direct internet access
- Database subnets should be completely isolated
- Only public subnets should have internet gateway routes

## 📊 **Cost Estimation**

Before deploying, estimate costs:

```bash
# Install terraform cost estimation tool (optional)
# tfcost plan.json

# Or manually calculate:
# Basic: NAT Gateway (~$45/month) + EIP (~$3.65/month)
# Multi-AZ: Same as basic
# Private-only: ~$0/month (VPC only)
# Complete: NAT Gateway + EIP (~$50/month)
```

## 🏷️ **Tag Validation**

Verify custom tags are applied:

```bash
# After deployment
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_info | jq -r '.id') --query 'Vpcs[0].Tags'
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_info | jq -r '.id')" --query 'Subnets[0].Tags'
```

## 📈 **Monitoring Setup** (Production)

For production testing, set up monitoring:

```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids $(terraform output -raw vpc_info | jq -r '.id') \
  --traffic-type ALL

# Set up CloudWatch alarms for NAT Gateway
aws cloudwatch put-metric-alarm \
  --alarm-name "NAT-Gateway-Data-Transfer" \
  --alarm-description "Monitor NAT Gateway data transfer" \
  --metric-name BytesOutToDestination \
  --namespace AWS/NATGateway
```

## ✅ **Pre-Publication Checklist**

Before publishing to Terraform Registry:

- [ ] All examples pass `terraform init`
- [ ] All examples pass `terraform validate` 
- [ ] All examples pass `terraform plan`
- [ ] At least one example tested with actual deployment
- [ ] README files are complete and accurate
- [ ] Cost estimates are documented
- [ ] Security best practices are followed
- [ ] No hardcoded credentials or secrets
- [ ] Module source paths are correct
- [ ] Provider versions are specified
- [ ] All outputs work as documented

## 🚀 **CI/CD Integration**

For automated testing in CI/CD:

```yaml
# .github/workflows/test-examples.yml
name: Test Examples
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.0
      - name: Test Examples
        run: |
          cd examples
          ./test-examples.sh
```

This ensures all examples work correctly before any changes are merged or published.