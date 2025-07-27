variable "AWS_REGION" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0b0ea68c435eb488d"
  description = "Image ID for the EC2 instance"
}

variable "default_volume_size" {
  default = 8 # size in GB
  description = "Default volume size for the EC2 instance"
}

variable "key_name" {
  default     = "user_key"
  description = "Name of the SSH key pair to use for the instance"
}

variable "environment" {
  default = "dev"
}