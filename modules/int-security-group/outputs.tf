output "security_group_id" {
  value       = aws_security_group.internal.id
  description = "ID of internal security group created"
}
