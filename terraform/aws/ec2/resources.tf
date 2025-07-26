resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  key_name               = aws_key_pair.user_key.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp2" # General Purpose SSD
  }

  tags = {
    Name = "ExampleInstance"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "Allow ssh & http"
  description = "Allow ssh & http inbound-outbound traffic"

  # Inbound rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  # Outbound rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0 # 0 means all ports
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

resource "aws_key_pair" "user_key" {
  key_name   = var.key_name
  public_key = file("terraform-key-aws.pub")

  # command to ssh into the instance
  # ssh -i terraform-key-aws ec2-user@<public-ip|public-dns>
}