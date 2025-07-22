provider "aws" {
  access_key = var.AWS_IAM_ACCESS_KEY # coming from secret.tf
  secret_key = var.AWS_IAM_SECRET_KEY # coming from secret.tf
  region = var.AWS_REGION
}