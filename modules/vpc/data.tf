data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "aws_linux" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_subnets" "all_subnets" {
  depends_on = [aws_subnet.public_subnets, aws_subnet.private_subnets]
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

data "aws_iam_user" "user_name" {
  user_name = var.user_name
}

data "tls_certificate" "eks" {
  depends_on = [aws_eks_cluster.eks]
  url        = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "iam_for_eks" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    sid =   "EKSClusterAssumeRole"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.user_name.arn]
    }
  }
}

data "aws_iam_policy_document" "iam_for_sa" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
      type        = "Federated"
    }
  }
}
