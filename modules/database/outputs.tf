output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds_db.endpoint
}
