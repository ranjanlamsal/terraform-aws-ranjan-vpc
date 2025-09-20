#!/bin/bash

# Test script for VPC module examples
# This script validates all examples without deploying resources

set -e  # Exit on any error

echo "🧪 Testing VPC Module Examples"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test an example
test_example() {
    local example_dir=$1
    local example_name=$(basename "$example_dir")
    
    echo -e "\n${BLUE}📁 Testing: $example_name${NC}"
    echo "-----------------------------------"
    
    cd "$example_dir"
    
    # Initialize
    echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
    if terraform init -no-color > init.log 2>&1; then
        echo -e "${GREEN}✅ Init successful${NC}"
    else
        echo -e "${RED}❌ Init failed${NC}"
        cat init.log
        return 1
    fi
    
    # Validate
    echo -e "${YELLOW}🔍 Validating configuration...${NC}"
    if terraform validate -no-color > validate.log 2>&1; then
        echo -e "${GREEN}✅ Validation successful${NC}"
    else
        echo -e "${RED}❌ Validation failed${NC}"
        cat validate.log
        return 1
    fi
    
    # Plan (dry run)
    echo -e "${YELLOW}📋 Creating plan (dry run)...${NC}"
    if terraform plan -no-color -out=tfplan > plan.log 2>&1; then
        echo -e "${GREEN}✅ Plan successful${NC}"
        
        # Show plan summary
        echo -e "${BLUE}📊 Plan Summary:${NC}"
        grep -E "(Plan:|No changes)" plan.log || echo "Plan details in plan.log"
    else
        echo -e "${RED}❌ Plan failed${NC}"
        cat plan.log
        return 1
    fi
    
    # Clean up
    rm -f init.log validate.log plan.log tfplan
    
    cd - > /dev/null
    echo -e "${GREEN}✅ $example_name: All tests passed!${NC}"
}

# Test all examples
EXAMPLES_DIR="/home/ranjan/Projects/Personal/learning-terraform/tf-own-module/examples"
failed_examples=()

for example in basic multi-az private-only complete; do
    if test_example "$EXAMPLES_DIR/$example"; then
        echo -e "${GREEN}✅ $example passed${NC}"
    else
        echo -e "${RED}❌ $example failed${NC}"
        failed_examples+=("$example")
    fi
done

# Summary
echo -e "\n${BLUE}📋 Test Summary${NC}"
echo "================================="

if [ ${#failed_examples[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All examples passed testing!${NC}"
    echo -e "${GREEN}✅ Your module is ready for Terraform Registry${NC}"
    exit 0
else
    echo -e "${RED}❌ Some examples failed:${NC}"
    for failed in "${failed_examples[@]}"; do
        echo -e "${RED}  - $failed${NC}"
    done
    exit 1
fi