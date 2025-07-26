provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_IAM_ACCESS_KEY # coming from secret.tf
  secret_key = var.AWS_IAM_SECRET_KEY # coming from secret.tf
}