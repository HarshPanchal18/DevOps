output "instance_ip" {
  value       = aws_instance.example.public_ip
  description = "Public IP address of the EC2 instance"
}

output "instance_dns" {
  value       = aws_instance.example.public_dns
  description = "Public DNS of the EC2 instance"
}