FROM python:3.12-slim

# Layer 1: base packages
RUN apt-get update && apt-get install -y git

# Layer 2: secrets copied in THE PROBLEM
COPY .env /app/.env
COPY credentials.json /root/.aws/credentials

# Layer 3: use the secrets to install private packages
# RUN pip install -r requirements.txt

# Layer 4: "clean up" — this does absolutely nothing to remove secrets
RUN rm /app/.env /root/.aws/credentials

COPY . /app/