provider "aws" {
  alias = "keys"
  access_key = var.AWS_IAM_ACCESS_KEY # coming from secret.tf
  secret_key = var.AWS_IAM_SECRET_KEY # coming from secret.tf
}

provider "aws" {
  alias = "west"
  region = "us-west-2" # Use the AWS provider for us-west-2
}