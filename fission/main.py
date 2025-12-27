from flask import request

def main() -> str:
    request_body = request.data
    return "Received request: " + request_body.decode()