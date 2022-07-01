terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "aws_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet_ids" "all_subnets" {
  depends_on = [aws_subnet.public_subnets, aws_subnet.private_subnets]
  vpc_id   = aws_vpc.vpc.id
}

data "aws_iam_user" "user_name" {
  user_name = var.user_name
}

data "tls_certificate" "eks" {
  depends_on = [aws_eks_cluster.eks]
  url        = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

