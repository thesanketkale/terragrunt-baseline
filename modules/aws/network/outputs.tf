output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the provisioned VPC."
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of IDs for the public subnets."
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of IDs for the private application subnets."
}

output "data_subnet_ids" {
  value       = aws_subnet.data[*].id
  description = "List of IDs for the isolated database/data subnets."
}

output "nat_gateway_ids" {
  value       = aws_nat_gateway.nat[*].id
  description = "List of NAT Gateway IDs."
}
