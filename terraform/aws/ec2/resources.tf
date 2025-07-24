resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  provider = aws.east # Use the AWS provider for us-east-1
}

resource "aws_security_group" "allow_ssh" {
  name = "Allow ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  egress {
    from_port = 0 # 0 means all ports
    to_port = 0
    protocol = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}