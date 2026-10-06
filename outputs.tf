output "vpc_id" {
  description = "ID of the platform VPC."
  value       = aws_vpc.platform.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by AZ."
  value       = { for az, subnet in aws_subnet.public : az => subnet.id }
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs keyed by AZ."
  value       = { for az, subnet in aws_subnet.isolated : az => subnet.id }
}
