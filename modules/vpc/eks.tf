resource "aws_security_group" "cluster_sg" {
  name        = "eks-cluster"
  description = "eks-cluster"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "cluster_admin_sg" {
  cidr_blocks = [
    for subnet in aws_subnet.public_subnets :
    subnet.cidr_block
  ]
  description       = "eks-control"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks" {
  name     = var.network_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [
      aws_security_group.cluster_sg.id
    ]
    subnet_ids = [
      for subnet in aws_subnet.private_subnets :
      subnet.id
    ]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.resource_controller,
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_version
  service_account_role_arn = aws_iam_role.worker_node.arn
}

resource "aws_eks_addon" "core_dns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = var.coredns_version
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_version
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.worker_node.arn
  subnet_ids = [
    aws_subnet.private_subnets["eu-west-1a"].id,
    aws_subnet.private_subnets["eu-west-1c"].id
  ]

  ami_type  = "AL2_x86_64"
  disk_size = var.eks_disk_size
  instance_types = [
    var.instance_type
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]

  labels = {
    "component" = "workers"
  }
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    data.tls_certificate.eks.certificates.0.sha1_fingerprint
  ]
  url = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}
