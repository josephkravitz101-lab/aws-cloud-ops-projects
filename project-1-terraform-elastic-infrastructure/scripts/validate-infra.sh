#!/usr/bin/env bash

# ==============================================================================
# SCRIPT NAME: validate-infra.sh
# PURPOSE: Local "Shift-Left" pre-flight verification tool for Terraform.
#          Validates formatting, syntax, and basic security postures locally 
#          before pushing code to the remote GitHub Actions pipeline.
# ==============================================================================

# 'set -e' tells Bash to immediately exit if any command returns a non-zero exit code.
# This prevents a broken script from continuing to run and masking upstream errors.
set -e

# Define ANSI escape codes for terminal color outputs to build a clean UI/UX.
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color (Resets the terminal styling back to default)

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}  Running Pre-Flight Infrastructure Checks ${NC}"
echo -e "${YELLOW}=========================================${NC}"

# ------------------------------------------------------------------------------
# STEP 1: DEPENDENCY CHECK (Ensure Terraform is installed locally)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 1/4] Checking local system tools...${NC}"

# 'command -v' checks the system's PATH variables to locate the terraform binary.
# '&> /dev/null' redirects standard output and errors to a black hole to keep the terminal silent.
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}[ERROR] Terraform CLI is not found in your environment.${NC}"
    echo -e "${RED}        Please install Terraform to utilize this local validation framework.${NC}"
    exit 1 # Exit with a failure status
fi
echo -e "${GREEN}[SUCCESS] Terraform CLI detected.${NC}"

# ------------------------------------------------------------------------------
# STEP 2: CODE FORMATTING VALIDATION
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 2/4] Verifying code style formatting...${NC}"

# 'terraform fmt' standardizes spacing and layout across configuration files.
# '-check' tells it to return an error code if files are messy, instead of auto-fixing them.
# '-recursive' forces the binary to look inside nested subdirectories (like modules).
if terraform fmt -check -recursive; then
    echo -e "${GREEN}[SUCCESS] All files strictly follow HashiCorp style guidelines!${NC}"
else
    echo -e "${RED}[ERROR] Code format discrepancies discovered.${NC}"
    echo -e "${YELLOW}[TIP] Run 'terraform fmt -recursive' in your workspace to auto-align code.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 3: INITIALIZATION & GRAMMAR/SYNTAX CHECK
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 3/4] Validating structural integrity & syntax...${NC}"

# We run an initialization without connecting to the S3 remote backend or DynamoDB.
# This makes the script portable, extremely fast, and runnable entirely offline.
# '> /dev/null' suppresses standard output logs so the developer only sees clean test summaries.
terraform init -backend=false -input=false > /dev/null

# 'terraform validate' executes an internal compilation check. It catches typos,
# reference errors to missing variables, block structure mistakes, and data type mismatches.
if terraform validate; then
    echo -e "${GREEN}[SUCCESS] Terraform configuration grammar is perfectly valid!${NC}"
else
    echo -e "${RED}[ERROR] Syntactical validation failed. Review the console logs above.${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# STEP 4: SECRET LEAKAGE PREVENTION (Credential Audit)
# ------------------------------------------------------------------------------
echo -e "\n${YELLOW}[Step 4/4] Auditing code for static credentials...${NC}"

# 'grep -R' executes a recursive pattern match through files and module subfolders.
# The search string utilizes a regular expression to look for 'access_key' OR 'secret_key'.
# '2>/dev/null' discards standard warning paths (like trying to read binary/hidden git folders).
if grep -R "access_key\|secret_key" *.tf modules/ 2>/dev/null; then
    echo -e "${RED}[WARNING] Security breach threat detected! Hardcoded AWS credential strings found.${NC}"
    echo -e "${RED}          To protect your cloud environment, do not commit these files to version control.${NC}"
    exit 1
else
    # This success message reinforces the keyless architecture choices of your project.
    echo -e "${GREEN}[SUCCESS] Zero static credentials found. OIDC keyless configuration posture is safe.${NC}"
fi

# ------------------------------------------------------------------------------
# EXECUTION SUMMARY
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  All local validation criteria passed!   ${NC}"
echo -e "${GREEN}  Your configuration is safe to push.     ${NC}"
echo -e "${GREEN}=========================================${NC}"