resource "aws_db_instance" "rds_db" {
    allocated_storage = 20
    db_subnet_group_name = aws_db_subnet_group.aws_multi_db_az_subnet.name
    identifier = "${var.project_name}rds-db"
    instance_class = "db.t3.micro"
    engine = "postgres:15.4"
    multi_az = true
    vpc_security_group_ids = [aws_security_group.sg_db.id]
    skip_final_snapshot = true
    username = "admin"
    password = "Admin12345"
    port = 5432
}

resource "aws_db_subnet_group" "aws_multi_db_az_subnet" {
    name = "${var.project_name}aws_multi_db_az_subnet"
  subnet_ids = [ aws_subnet.privateDB_subnet_A.id, aws_subnet.privateDB_subnet_B.id ]
}