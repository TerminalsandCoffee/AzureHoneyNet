#!/bin/bash
# Azure Honeynet Deployment Script
# This script automates the Terraform deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

echo -e "${GREEN}Azure Honeynet Deployment Script${NC}"
echo "=================================="

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI not found. Please install it first.${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform not found. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Logging in...${NC}"
    az login
fi

echo -e "${GREEN}✓ Prerequisites met${NC}"

# Check for terraform.tfvars
if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
    echo -e "\n${YELLOW}terraform.tfvars not found.${NC}"
    echo "Creating from example..."
    cp "$TERRAFORM_DIR/terraform.tfvars.example" "$TERRAFORM_DIR/terraform.tfvars"
    echo -e "${YELLOW}Please edit terraform/terraform.tfvars with your values before continuing.${NC}"
    echo "Press Enter to continue after editing, or Ctrl+C to cancel..."
    read
fi

# Navigate to terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo -e "\n${YELLOW}Initializing Terraform...${NC}"
terraform init

# Plan
echo -e "\n${YELLOW}Running Terraform plan...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo -e "\n${YELLOW}Review the plan above.${NC}"
read -p "Do you want to apply these changes? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    rm -f tfplan
    exit 0
fi

# Apply
echo -e "\n${YELLOW}Applying Terraform configuration...${NC}"
terraform apply tfplan

# Clean up plan file
rm -f tfplan

# Display outputs
echo -e "\n${GREEN}Deployment complete!${NC}"
echo -e "\n${YELLOW}Resource Information:${NC}"
terraform output

echo -e "\n${GREEN}Next Steps:${NC}"
echo "1. Import Sentinel analytics rules from AzureHoneyNet/Sentinel-Analytics-Rules/"
echo "2. Configure data connectors in Microsoft Sentinel"
echo "3. Run attack simulation scripts to test detection"
echo "4. Monitor security metrics in Log Analytics"

