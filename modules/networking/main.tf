###################
###     VPC     ###
###################

# Create the main Virtual Private Cloud (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway to allow external communication for resources in public subnets
resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

######################
### Public Subnets ###
######################

# Public subnet in the first Availability Zone
resource "aws_subnet" "public_subnet_A" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1) # e.g., 172.16.1.0/24
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true # Instances get a public IP automatically

  tags = {
    Name = "${var.project_name}-publicSubnetA"
    # Required for external load balancers
    "kubernetes.io/role/elb" = "1"
    # Required for EKS
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Public subnet in the second Availability Zone
resource "aws_subnet" "public_subnet_B" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2) # e.g., 172.16.2.0/24
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  # Tags for the subnet
  tags = {
    Name = "${var.project_name}-publicSubnetB"
    # Required for external load balancers
    "kubernetes.io/role/elb" = "1"
    # Required for EKS
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Route table for public subnets directing internet-bound traffic to the Internet Gateway
resource "aws_route_table" "main_public_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_internet_gateway.id
  }

  tags = {
    Name = "${var.project_name}-publicSubnetTable"
  }
}

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

# Private subnet in the first Availability Zone (typically for EKS nodes / Backend apps)
resource "aws_subnet" "private_subnet_A" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-privateSubnetA"
    # Required for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
    # Required for EKS
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Private subnet in the second Availability Zone
resource "aws_subnet" "private_subnet_B" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 20)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-privateSubnetB"
    # Required for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
    # Required for EKS
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

#########################
### Databases Subnets ###
#########################

# Isolated subnets specifically for the Database layer
resource "aws_subnet" "privateDB_subnet_A" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 100)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-privateDBSubnetA"
  }
}

resource "aws_subnet" "privateDB_subnet_B" {
  vpc_id = aws_vpc.main_vpc.id
  # The cidrsubnet function is used to calculate the subnet's CIDR block based on the VPC's CIDR block.
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 200)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-privateDBSubnetB"
  }
}

# Route table for Database subnets (no internet access route means completely private)
resource "aws_route_table" "route_table_db_NAT" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-db-routetable"
  }
}

resource "aws_route_table_association" "route_table_db_association_A" {
  subnet_id      = aws_subnet.privateDB_subnet_A.id
  route_table_id = aws_route_table.route_table_db_NAT.id
}

resource "aws_route_table_association" "route_table_db_association_B" {
  subnet_id      = aws_subnet.privateDB_subnet_B.id
  route_table_id = aws_route_table.route_table_db_NAT.id
}

############################
### NAT Gateways Routing ###
############################

# Elastic IPs for NAT Gateways
resource "aws_eip" "azA_eip" {
  domain = "vpc"
}

resource "aws_eip" "azB_eip" {
  domain = "vpc"
}

# NAT Gateway for AZ A (provides internet access to private subnet A)
resource "aws_nat_gateway" "azA_nat_gw" {
  allocation_id = aws_eip.azA_eip.id
  subnet_id     = aws_subnet.public_subnet_A.id

  tags = {
    Name = "${var.project_name}-nat-gateway-azA"
  }

  depends_on = [aws_internet_gateway.main_internet_gateway]
}

# NAT Gateway for AZ B (provides internet access to private subnet B)
resource "aws_nat_gateway" "azB_nat_gw" {
  allocation_id = aws_eip.azB_eip.id
  subnet_id     = aws_subnet.public_subnet_B.id

  tags = {
    Name = "${var.project_name}-nat-gateway-azB"
  }

  depends_on = [aws_internet_gateway.main_internet_gateway]
}

# Route tables to route internet traffic from private subnets to respective NAT Gateways
resource "aws_route_table" "route_table_A_NAT" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.azA_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-private-rt-azA"
  }
}

resource "aws_route_table_association" "route_table_A_NAT_association" {
  subnet_id      = aws_subnet.private_subnet_A.id
  route_table_id = aws_route_table.route_table_A_NAT.id
}

resource "aws_route_table" "route_table_B_NAT" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.azB_nat_gw.id
  }
  tags = {
    Name = "${var.project_name}-private-rt-azB"
  }
}

resource "aws_route_table_association" "route_table_B_NAT_association" {
  subnet_id      = aws_subnet.private_subnet_B.id
  route_table_id = aws_route_table.route_table_B_NAT.id
}
