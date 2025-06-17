#!/bin/bash

set -e

JIRA_CONFIG="$HOME/.jiraconfig"
VIM_PLUGIN_DIR="$HOME/.vim/plugin"

if [ ! -f "jira.vim" ]; then
    echo "Error: jira.vim not found"
    exit 1
fi

if [ ! -f "$JIRA_CONFIG" ]; then
    echo "Creating JIRA configuration..."
    
    read -p "JIRA URL: " JIRA_URL
    read -p "Username: " JIRA_USERNAME
    read -s -p "API Token: " JIRA_API_TOKEN
    echo
    read -p "Project: " JIRA_PROJECT
    
    cat > "$JIRA_CONFIG" << EOF
{
  "url": "$JIRA_URL",
  "username": "$JIRA_USERNAME",
  "api_token": "$JIRA_API_TOKEN",
  "project": "$JIRA_PROJECT"
}
EOF
    
    chmod 600 "$JIRA_CONFIG"
    echo "Config saved to $JIRA_CONFIG"
else
    echo "Using existing config at $JIRA_CONFIG"
fi

echo "Installing Vim plugin..."
mkdir -p "$VIM_PLUGIN_DIR"
cp jira.vim "$VIM_PLUGIN_DIR/"

echo "Installation complete"
echo "Use \\j in Vim to search JIRA tickets"
