#############
###  ECR  ###
#############

resource "aws_ecr_repository" "frontend_ecr_repo" {
  name = "${var.project_name}frontend_ecr_repo"

  force_delete = true
}

resource "aws_ecr_repository" "backend_ecr_repo" {
  name = "${var.project_name}backend_ecr_repo"

  force_delete = true
}