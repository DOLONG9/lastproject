output "vpc1_public_subnets_id" {
  value = aws_subnet.vpc1_public_subnets[*].id
}

output "vpc1_private_subnets_id" {
  value = aws_subnet.vpc1_private_subnets[*].id
}
