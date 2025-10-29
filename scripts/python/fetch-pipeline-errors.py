# Query: Can you authenticate with an API (like a CI/CD tool), fetch the deployment logs for a specific job, and print out only the error messages in Python?

import requests, re

API_TOKEN = "YOUR_PAT_TOKEN"

# https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#download-job-logs-for-a-workflow-run
def get_job_logs(owner: str, repo: str, job_id: int = 0) -> str:
        job_url = f"https://api.github.com/repos/{owner}/{repo}/actions/jobs/{job_id}/logs"
        headers = {"Authorization": f"Bearer {API_TOKEN}",
                   "Accept": "application/vnd.github+json"}

        response = requests.get(job_url,headers=headers)
        response.raise_for_status() # Raise an HTTP error, if one occurred.
        return response.text

# https://docs.github.com/en/rest/actions/workflow-jobs?apiVersion=2022-11-28#list-jobs-for-a-workflow-run
def get_run_logs(owner: str, repo: str, run_id: int = 0) -> str:
        run_url = f"https://api.github.com/repos/{owner}/{repo}/actions/runs/{run_id}/jobs"
        headers = {"Authorization": f"Bearer {API_TOKEN}",
                   "Accept": "application/vnd.github+json"}

        response = requests.get(run_url,headers=headers)
        response.raise_for_status() # Raise an HTTP error, if one occurred.
        return response.text

def extract_errors(logs: str) -> list[str]:
        error_pattern = re.compile(r".*(ERROR|Error|Exception).*")
        return [line for line in logs.splitlines() if error_pattern.match(line)]

if __name__ == "__main__":
        logs = get_job_logs("HarshPanchal18","HarshPanchal18.github.io", job_id=46111499653)
        print("Job Logs")
        # print(logs)

        errors = extract_errors(logs)

        if errors:
                print("Error messages found: ")
                for error in errors:
                    print(error)
        else:
                print("No error found in logs")

        logs = get_run_logs("HarshPanchal18","HarshPanchal18.github.io", run_id=16324669641)
        print("Job Run Logs")
        # print(logs)

        errors = extract_errors(logs)

        if errors:
                print("Error messages found: ")
                for error in errors:
                    print(error)
        else:
                print("No error found in logs")