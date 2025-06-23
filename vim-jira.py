#! /usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests",
# ]
# ///

import sys
import json
import requests
from requests.auth import HTTPBasicAuth
import os


class JiraSearcher:
    def __init__(self):
        self.load_config()

        if not all([self.jira_url, self.username, self.api_token]):
            print(
                "Missing JIRA configuration. Set environment variables or config file."
            )
            sys.exit(1)

    def load_config(self):
        config_file = os.path.expanduser("~/.jiraconfig")
        if os.path.exists(config_file):
            try:
                with open(config_file, "r") as f:
                    config = json.load(f)
                    self.jira_url = config.get("url")
                    self.username = config.get("username")
                    self.api_token = config.get("api_token")
                    self.project = config.get("project")
            except Exception as e:
                print(f"Error reading config file: {e}")
                sys.exit(1)
        else:
            print("Configuration file not found. Please create ~/.jiraconfig.")
            sys.exit(1)

    def search_tickets(self, search_term, max_results=50):
        jql_parts = []
        if search_term:
            jql_parts = [f'text ~ "{search_term}" OR summary ~ "{search_term}"']

        if hasattr(self, "project") and self.project:
            jql_parts.append(f'project = "{self.project}"')

        jql_parts.append('status != "Canceled"')

        jql = " AND ".join([f"({part})" for part in jql_parts])

        url = f"{self.jira_url}/rest/api/3/search/jql"

        params = {
            "jql": jql,
            "maxResults": max_results,
            "fields": "key,summary,description,status,assignee,priority,issuetype,project",
        }

        try:
            response = requests.get(
                url,
                params=params,
                auth=HTTPBasicAuth(self.username, self.api_token),
                headers={"Accept": "application/json"},
                timeout=30,
            )

            if response.status_code == 401:
                print("Authentication failed. Check username and API token.")
                return []
            elif response.status_code != 200:
                print(
                    f"JIRA API error: {response.status_code} - {response.text}"
                )
                return []

            data = response.json()
            return self.format_results(data.get("issues", []))

        except requests.exceptions.Timeout:
            print("Request timed out")
            return []
        except requests.exceptions.ConnectionError:
            print("Connection error. Check JIRA URL.")
            return []
        except Exception as e:
            print(f"Unexpected error: {e}")
            return []

    def format_results(self, issues):
        results = []

        issues.sort(
            key=lambda x: (
                x.get("fields", {}).get("issuetype", {}).get("name", ""),
                x.get("key", ""),
            )
        )

        for issue in issues:
            fields = issue.get("fields", {})

            ticket = {
                "key": issue.get("key", "UNKNOWN"),
                "summary": fields.get("summary", "No summary"),
                "description": self.truncate_text(fields.get("description", "")),
                "status": fields.get("status", {}).get("name", "Unknown"),
                "priority": fields.get("priority", {}).get("name", "Unknown"),
                "issuetype": fields.get("issuetype", {}).get("name", "Unknown"),
                "assignee": self.get_assignee_name(fields.get("assignee")),
                "assignedToMe": fields.get("assignee") and fields.get("assignee", {}).get("emailAddress") == self.username,
                "url": f"{self.jira_url}/browse/{issue.get('key', '')}",
            }

            results.append(ticket)

        return results

    def get_assignee_name(self, assignee):
        if not assignee:
            return "Unassigned"
        return assignee.get("displayName", assignee.get("name", "Unknown"))

    def truncate_text(self, text, max_length=100):
        if not text:
            return ""
        if len(text) <= max_length:
            return text
        return text[: max_length - 3] + "..."


def main():
    search_term = sys.argv[1] if len(sys.argv) > 1 else None

    searcher = JiraSearcher()
    results = searcher.search_tickets(search_term)

    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
