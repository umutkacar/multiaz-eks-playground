output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "natgw_outbound_ips" {
  description = "Outbound Public IP list for external source filtering"
  value       = aws_eip.nat_eip[*].public_ip
}