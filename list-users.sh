#!/bin/bash

##########################################################
# Script Name : list-users.sh
# Author      : Tejesh
# Version     : v1.2
# Date        : 13-May-2025
#
# Purpose     : Lists GitHub collaborators with read access
#               using GitHub REST API and jq parser.
#
# Requirements:
#   - jq installed (sudo apt install jq)
#   - Export GitHub credentials:
#       export username="your_username"
#       export token="your_token"
#
# Usage:
#   ./list-users.sh <org_name> <repo_name>
##########################################################

# GitHub API base URL
API_URL="https://api.github.com"

# GitHub credentials (read from environment variables)
USERNAME=$username
TOKEN=$token

# User input
REPO_OWNER=$1
REPO_NAME=$2

# Helper function to validate input and prerequisites
function helper {
    expected_cmd_args=2
    if [ $# -ne $expected_cmd_args ]; then
        echo "Incorrect usage."
        echo "Usage: ./list-users.sh <org_name> <repo_name>"
        exit 1
    fi

    if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
        echo "Please export 'username' and 'token' before running the script."
        exit 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "'jq' is required but not installed. Run: sudo apt install jq"
        exit 1
    fi
}

# Call helper at the start
helper "$@"

# Function to make a GET request to GitHub API
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    curl -s -u "${USERNAME}:${TOKEN}" "$url"
}

# Function to list users with read access
function list_users_with_read_access {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    collaborators="$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')"

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# Main execution
echo "Checking collaborators in ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access
