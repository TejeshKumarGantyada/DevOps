#!/bin/bash

##########################################################
# Script Name : list-users.sh
# Author      : Tejesh
# Version     : v1.1
# Date        : 13-May-2025
#
# Purpose     : This script connects to the GitHub API and
#               lists all users with read access (pull permission)
#               to a given GitHub repository.
#
# Requirements:
#   - jq must be installed (sudo apt install jq)
#   - Export your GitHub username and PAT (token)
#       export username="your_username"
#       export token="your_token"
#
# Usage:
#   ./list-users.sh <org_name> <repo_name>
##########################################################

# GitHub API base URL
API_URL="https://api.github.com"

# GitHub credentials (must be set in the environment)
USERNAME=$username
TOKEN=$token

# User input
REPO_OWNER=$1
REPO_NAME=$2

# Helper function to print messages with color
function log_info {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

function log_error {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Function to call GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Make GET request with authentication
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read (pull) access
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    log_info "Fetching collaborators for ${REPO_OWNER}/${REPO_NAME}..."
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    if [[ -z "$collaborators" ]]; then
        log_info "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        log_info "Users with read access:"
        echo "$collaborators"
    fi
}

# Check if all required inputs are provided
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    log_error "GitHub credentials not set. Please export 'username' and 'token'."
    exit 1
fi

if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    log_error "Usage: ./list-users.sh <org_name> <repo_name>"
    exit 1
fi

# Execute main function
list_users_with_read_access
