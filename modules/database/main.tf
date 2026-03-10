###############################
### Database Security Group ###
###############################

# Security group to restrict access to the database
resource "aws_security_group" "sg_db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-sg_db"
  }
}

# Ingress rule allowing the EKS cluster nodes to communicate with the RDS instance
resource "aws_vpc_security_group_ingress_rule" "allow_eks_to_db" {
  security_group_id            = aws_security_group.sg_db.id

  # This allows traffic from any resource that has the EKS cluster's security group attached, 
  # which is more flexible than hardcoding IPs or IP ranges.
  referenced_security_group_id = var.eks_cluster_security_group_id

  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

#######################
### DB Subnet Group ###
#######################

# Subnet group specifying which subnets the RDS instance is allowed to use
resource "aws_db_subnet_group" "aws_multi_db_az_subnet" {
  name       = "${var.project_name}-multi-db-az-subnet"

  # List of subnet IDs for the RDS instance
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

###############################
### PostgreSQL RDS Instance ###
###############################

resource "aws_db_instance" "rds_db" {
  # The amount of storage allocated to the database instance in GiB.
  allocated_storage    = var.db_allocated_storage

  db_subnet_group_name = aws_db_subnet_group.aws_multi_db_az_subnet.name
  identifier           = "${var.project_name}rds-db"
  instance_class       = var.db_instance_class

  engine               = "postgres"
  engine_version       = "15.8"

  # Multi-AZ deployment for high availability
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.sg_db.id]

  # Useful for dev/lab environments so destroy completes quickly
  skip_final_snapshot = true
  username            = var.db_username
  password            = var.db_password
  port                = 5432
}
