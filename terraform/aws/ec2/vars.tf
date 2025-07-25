variable "AWS_REGION" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0c02fb55956c7d316"
}

variable "volume_size" {
  default = 8
}