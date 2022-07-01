output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = {
    "public" : [
      for subnet in aws_subnet.public_subnets :
      subnet.id
    ],
    "private" : [
      for subnet in aws_subnet.private_subnets :
      subnet.id
    ]
  }
}

output "subnet_cidr_blocks" {
  value = {
    "public" : [
      for subnet in aws_subnet.public_subnets :
      subnet.cidr_block
    ],
    "private" : [
      for subnet in aws_subnet.private_subnets :
      subnet.cidr_block
    ]
  }
}

output "stepstone_instance_id" {
  value = aws_instance.stepstone.id
}

output "nat_instance_ip" {
  value = aws_instance.stepstone.public_ip
}

output "k8s_arn" {
  value = aws_eks_cluster.eks.arn
}

output "k8s_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "route_table_ids" {
  value = {
    public : aws_route_table.public_rt.id,
    private : aws_route_table.private_rt.id
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
