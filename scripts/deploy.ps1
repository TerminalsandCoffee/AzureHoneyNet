# Azure Honeynet Deployment Script (PowerShell)
# This script automates the Terraform deployment process

param(
    [switch]$SkipPlan,
    [switch]$Destroy
)

$ErrorActionPreference = "Stop"

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$TerraformDir = Join-Path $ProjectRoot "terraform"

Write-Host "Azure Honeynet Deployment Script" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow

# Check Azure CLI
try {
    $null = az --version
} catch {
    Write-Host "Error: Azure CLI not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Check Terraform
try {
    $null = terraform version
} catch {
    Write-Host "Error: Terraform not found. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
try {
    $null = az account show 2>$null
} catch {
    Write-Host "Not logged in to Azure. Logging in..." -ForegroundColor Yellow
    az login
}

Write-Host "✓ Prerequisites met" -ForegroundColor Green

# Check for terraform.tfvars
$TfVarsPath = Join-Path $TerraformDir "terraform.tfvars"
if (-not (Test-Path $TfVarsPath)) {
    Write-Host "`nterraform.tfvars not found." -ForegroundColor Yellow
    Write-Host "Creating from example..."
    Copy-Item (Join-Path $TerraformDir "terraform.tfvars.example") $TfVarsPath
    Write-Host "Please edit terraform/terraform.tfvars with your values before continuing." -ForegroundColor Yellow
    Write-Host "Press Enter to continue after editing, or Ctrl+C to cancel..."
    Read-Host
}

# Navigate to terraform directory
Set-Location $TerraformDir

if ($Destroy) {
    Write-Host "`nDestroying infrastructure..." -ForegroundColor Yellow
    terraform destroy
    Write-Host "`nInfrastructure destroyed." -ForegroundColor Green
    exit 0
}

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Yellow
terraform init

# Plan
if (-not $SkipPlan) {
    Write-Host "`nRunning Terraform plan..." -ForegroundColor Yellow
    terraform plan -out=tfplan

    # Ask for confirmation
    Write-Host "`nReview the plan above." -ForegroundColor Yellow
    $confirm = Read-Host "Do you want to apply these changes? (yes/no)"

    if ($confirm -ne "yes") {
        Write-Host "Deployment cancelled." -ForegroundColor Red
        Remove-Item -ErrorAction SilentlyContinue tfplan
        exit 0
    }
}

# Apply
Write-Host "`nApplying Terraform configuration..." -ForegroundColor Yellow
if (Test-Path tfplan) {
    terraform apply tfplan
    Remove-Item tfplan
} else {
    terraform apply -auto-approve
}

# Display outputs
Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "`nResource Information:" -ForegroundColor Yellow
terraform output

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "1. Import Sentinel analytics rules from AzureHoneyNet/Sentinel-Analytics-Rules/"
Write-Host "2. Configure data connectors in Microsoft Sentinel"
Write-Host "3. Run attack simulation scripts to test detection"
Write-Host "4. Monitor security metrics in Log Analytics"

