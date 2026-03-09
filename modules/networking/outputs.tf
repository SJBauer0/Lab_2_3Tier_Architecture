output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_subnet_A.id, aws_subnet.public_subnet_B.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_subnet_A.id, aws_subnet.private_subnet_B.id]
}

output "db_subnet_ids" {
  description = "The IDs of the database subnets"
  value       = [aws_subnet.privateDB_subnet_A.id, aws_subnet.privateDB_subnet_B.id]
}
