output "instance_public_ip" {
  value       = [for instance in aws_instance.example : instance.public_ip]
  description = "Public IP address of the EC2 instance"
}

output "instance_dns" {
  value       = [for instance in aws_instance.example : instance.public_dns]
  description = "Public DNS of the EC2 instance"
}

output "instance_private_ip" {
  value       = [for instance in aws_instance.example : instance.private_ip]
  description = "Private IP address of the EC2 instance"
}