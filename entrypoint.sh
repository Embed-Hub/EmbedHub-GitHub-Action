#!/bin/bash
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse inputs
API_KEY="$1"
ORGANIZATION="$2"
PROJECT="$3"
FILES="$4"
TARGET_PATH="$5"
WORKING_DIR="$6"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Validate required inputs
if [ -z "$API_KEY" ]; then
    print_error "API key is required. Please set the 'api-key' input."
    exit 1
fi

if [ -z "$ORGANIZATION" ]; then
    print_error "Organization is required. Please set the 'organization' input."
    exit 1
fi

if [ -z "$PROJECT" ]; then
    print_error "Project is required. Please set the 'project' input."
    exit 1
fi

if [ -z "$FILES" ]; then
    print_error "Files pattern is required. Please set the 'files' input."
    exit 1
fi

# Change to working directory if specified
if [ -n "$WORKING_DIR" ] && [ "$WORKING_DIR" != "." ]; then
    print_info "Changing to working directory: $WORKING_DIR"
    cd "$WORKING_DIR" || {
        print_error "Failed to change to working directory: $WORKING_DIR"
        exit 1
    }
fi

# Configure the EmbedHub CLI with API key
print_info "Configuring EmbedHub CLI..."
embedhub config set api-key "$API_KEY" > /dev/null 2>&1

# Construct the project path
PROJECT_PATH="$ORGANIZATION/$PROJECT"

print_info "Uploading to project: $PROJECT_PATH"
print_info "Files pattern: $FILES"
if [ -n "$TARGET_PATH" ]; then
    print_info "Target path: $TARGET_PATH"
else
    print_info "Target path: Using default paths based on file types"
fi

# Expand glob patterns and check if files exist
shopt -s nullglob
file_array=($FILES)
shopt -u nullglob

if [ ${#file_array[@]} -eq 0 ]; then
    print_error "No files found matching pattern: $FILES"
    exit 1
fi

print_success "Found ${#file_array[@]} file(s) matching pattern"

# Build the push command
PUSH_CMD="embedhub push"

# Add path flag if specified
if [ -n "$TARGET_PATH" ]; then
    PUSH_CMD="$PUSH_CMD $FILES $PROJECT_PATH --path $TARGET_PATH"
else
    PUSH_CMD="$PUSH_CMD $FILES $PROJECT_PATH"
fi

# Execute the upload
print_info "Starting upload..."
echo "----------------------------------------"

if eval "$PUSH_CMD"; then
    echo "----------------------------------------"
    print_success "Successfully uploaded files to EmbedHub"

    # Set GitHub Action outputs
    echo "uploaded=true" >> $GITHUB_OUTPUT
    echo "file_count=${#file_array[@]}" >> $GITHUB_OUTPUT
    exit 0
else
    echo "----------------------------------------"
    print_error "Failed to upload files to EmbedHub"

    # Set GitHub Action outputs
    echo "uploaded=false" >> $GITHUB_OUTPUT
    echo "file_count=0" >> $GITHUB_OUTPUT
    exit 1
fi
