###################
###     VPC     ###
###################

resource "aws_vpc" "main_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.project_name}vpc"
  }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}ig"
  }
}

######################
### Public Subnets ###
######################

resource "aws_subnet" "public_subnet_A" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "172.16.1.0/24"
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}publicSubnetA"
    "kubernetes.io/role/elb" = "1"
    "kuberbernetes.io/cluster/${var.project_name}-main-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "public_subnet_B" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "172.16.2.0/24"
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}publicSubnetB"
    "kubernetes.io/role/elb" = "1"
    "kuberbernetes.io/cluster/${var.project_name}-main-eks-cluster" = "owned"
  }
}

### Route Table  ###
resource "aws_route_table" "main_public_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}publicSubnetTable"
  }
}

### Route Table Association ###

resource "aws_route_table_association" "public_subnet_A_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_A.id
  route_table_id = aws_route_table.main_public_table.id
}

resource "aws_route_table_association" "public_subnet_B_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_B.id
  route_table_id = aws_route_table.main_public_table.id
}

#######################
### Private Subnets ###
#######################

resource "aws_subnet" "private_subnet_A" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.project_name}privateSubnetA"
    "kubernetes.io/role/internal-elb" = "1"
    "kuberbernetes.io/cluster/${var.project_name}-main-eks-cluster" = "owned"
  }
}

### Route Table Subnet A Pointing to NAT Gateway ###

resource "aws_route_table" "route_table_A_NAT" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.azA_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}private-rt-azA"
  }

}

### Table Association ###

resource "aws_route_table_association" "route_table_A_NAT_association" {
  subnet_id      = aws_subnet.private_subnet_A.id
  route_table_id = aws_route_table.route_table_A_NAT.id
}


resource "aws_subnet" "private_subnet_B" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.project_name}privateSubnetB"
    "kubernetes.io/role/internal-elb" = "1"
    "kuberbernetes.io/cluster/${var.project_name}-main-eks-cluster" = "owned"
  }
}

### Route Table Subnet B Pointing to NAT Gateway ###

resource "aws_route_table" "route_table_B_NAT" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.azB_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}private-rt-azB"
  }

}

### Table Association ###

resource "aws_route_table_association" "route_table_B_NAT_association" {
  subnet_id      = aws_subnet.private_subnet_B.id
  route_table_id = aws_route_table.route_table_B_NAT.id
}

#########################
### Databases Subnets ###
#########################

resource "aws_subnet" "privateDB_subnet_A" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.100.0/24"
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.project_name}privateDBSubnetA"
  }
}

resource "aws_subnet" "privateDB_subnet_B" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "172.16.200.0/24"
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.project_name}privateDBSubnetB"
  }
}

### Route Table Subnet Pointing to nothing ###

resource "aws_route_table" "route_table_db_NAT" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}db-routetable"
  }

}

### Table Association ###

resource "aws_route_table_association" "route_table_db_association_A" {
  subnet_id      = aws_subnet.privateDB_subnet_A.id
  route_table_id = aws_route_table.route_table_db_NAT.id
}

resource "aws_route_table_association" "route_table_db_association_B" {
  subnet_id      = aws_subnet.privateDB_subnet_B.id
  route_table_id = aws_route_table.route_table_db_NAT.id
}

############################
### NAT Gateways Subnets ###
############################

resource "aws_eip" "azA_eip" {
  domain = "vpc"
}

resource "aws_eip" "azB_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "azA_nat_gw" {
  allocation_id = aws_eip.azA_eip.id

  subnet_id = aws_subnet.public_subnet_A.id

  tags = {
    Name = "[${var.project_name}]nat-gateway-azA"
  }

  depends_on = [aws_internet_gateway.main_internet_gateway]
}

resource "aws_nat_gateway" "azB_nat_gw" {
  allocation_id = aws_eip.azB_eip.id

  subnet_id = aws_subnet.public_subnet_B.id

  tags = {
    Name = "[${var.project_name}]nat-gateway-azB"
  }

  depends_on = [aws_internet_gateway.main_internet_gateway]
}

#############################
### Elastic Load Balancer ###
#############################

resource "aws_lb" "network_els" {
  name               = "${var.project_name}network-els"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private_subnet_A.id, aws_subnet.private_subnet_B.id]

  tags = {
    Name = "${var.project_name}network-els"
  }
}

#################################
### Application Load Balancer ###
#################################

resource "aws_lb" "application_els" {
  name               = "${var.project_name}application-els"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_A.id, aws_subnet.public_subnet_B.id]

  tags = {
    Name = "${var.project_name}application-els"
  }
}