provider "aws" {
  alias      = "keys"
  access_key = var.AWS_IAM_ACCESS_KEY # coming from secret.tf
  secret_key = var.AWS_IAM_SECRET_KEY # coming from secret.tf
}

provider "aws" {
  alias = "east"
  region = "us-east-1" # Use the AWS provider for us-east-1
}