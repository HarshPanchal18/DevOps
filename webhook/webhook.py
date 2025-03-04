import requests
import json

webhook_url = "http://127.0.0.1:5000/webhook"

data = {
    'name':'Harsh',
    'age': '21'
}

request = requests.post(webhook_url, json.dumps(data), headers={'Content-Type': 'application/json'}, verify=False)

webhook_url = "http://127.0.0.1:5000/webhook1"

data = {
    'name':'Harsh',
    'age': '22'
}

request = requests.post(webhook_url, json.dumps(data), headers={'Content-Type': 'application/json'}, verify=False)
