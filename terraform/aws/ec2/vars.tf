variable "AWS_REGION" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0b0ea68c435eb488d"
}

variable "volume_size" {
  default = 8
}

variable "key_name" {
  default     = "user_key"
  description = "Name of the SSH key pair to use for the instance"
}
