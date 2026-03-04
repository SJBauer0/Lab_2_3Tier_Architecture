#######################
### Security Groups ###
#######################

#################################
### Application Load Balancer ###
#################################

resource "aws_security_group" "sg_aplication_load_balancer" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}sg_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_http_alb" {
  security_group_id = aws_security_group.sg_aplication_load_balancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_traffic_to_nlb" {
  security_group_id            = aws_security_group.sg_aplication_load_balancer.id
  referenced_security_group_id = aws_security_group.sg_network_load_balancer.id

  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}


################################
### Networking Load Balancer ###
################################

resource "aws_security_group" "sg_network_load_balancer" {
  name   = "${var.project_name}-nlb-sg"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}sg_nlb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nlb_allow_alb_traffic" {
  security_group_id            = aws_security_group.sg_network_load_balancer.id
  referenced_security_group_id = aws_security_group.sg_aplication_load_balancer.id

  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  tags = {
    Name = "${var.project_name}sg_nlb"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_access_eks" {
  security_group_id            = aws_security_group.sg_network_load_balancer.id
  referenced_security_group_id = aws_security_group.sg_eksWorker.id

  from_port   = 30000
  ip_protocol = "tcp"
  to_port     = 32767

}
####################################
### EKS Worker Security Balancer ###
####################################

resource "aws_security_group" "sg_eksWorker" {
  name   = "${var.project_name}-eks-worker-sg"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}sg_eks_worker"
  }
}

resource "aws_vpc_security_group_ingress_rule" "traffic_nlb_nodes" {
  security_group_id            = aws_security_group.sg_eksWorker.id
  referenced_security_group_id = aws_security_group.sg_network_load_balancer.id

  from_port   = 30000
  ip_protocol = "tcp"
  to_port     = 32767

}

resource "aws_vpc_security_group_egress_rule" "allow_traffic_internet" {
  security_group_id = aws_security_group.sg_eksWorker.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

###############################
### Database Security Group ###
###############################

resource "aws_security_group" "sg_db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}sg_db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_eks_to_db" {
  security_group_id            = aws_security_group.sg_db.id
  referenced_security_group_id = aws_security_group.sg_eksWorker.id

  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432

}


