# vim-jira

A simple vim function and python script that let you search JIRA tickets and insert ticket IDs directly into your documents / commit message.

![](docs/demo.gif)

## Requirements
- Python 3.x
- `uv`
- `requests` library (`pip install requests`)
- vim
- JIRA API token

## Installation

```bash
make install
```

This will prompt you for the configuration information if a `~/.jiraconfig` file is not present.

### Configuration

The installer will prompt for:
- **JIRA URL**: `https://company.atlassian.net`
- **Username**: Your email address
- **API Token**: Get from [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
- **Project Name**: Your project name (e.g., `Company`)

Configuration is saved to `~/.jiraconfig`:
```json
{
  "url": "https://company.atlassian.net",
  "username": "your-email@company.com",
  "api_token": "your-api-token-here",
  "project": "Company"
}
```

## Usage

In Vim:

| Command | Key Mapping | Description |
|---------|-------------|-------------|
| `:JiraSearch` | `\j` | Search all issues and epics |

## Customization

### Change Key Mappings

Add to your `.vimrc`:

```vim
let g:jira_search_mapping = '<leader>jj'  " Use \jj instead of \j
```

### Change Script Path

```vim
let g:jira_script_path = '/usr/local/bin/jira'
```
