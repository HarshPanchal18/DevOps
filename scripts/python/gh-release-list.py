import requests

OWNER="minio"
REPO="operator"

# curl -s https://api.github.com/repos/OWNER/REPO/releases | jq -r '.[].name'

url = f"https://api.github.com/repos/{OWNER}/{REPO}/releases"
releases = requests.get(url).json()

names = [r["name"] for r in releases]
print("\n".join(names))
