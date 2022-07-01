resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name  = var.network_name
    Usage = "k8s"
  }
}

# NETWORKING
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, each.value[0], each.value[1])

  tags = {
    Name = format("%s-%s-%s",
      var.network_name,
      "public",
      element(split("-", each.key), length(split("-", each.key)) - 1)
    )
    Usage                    = "public"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.network_name, "public")
  }
}

resource "aws_route_table_association" "public_rta" {
  for_each = aws_subnet.public_subnets

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = each.value.id
}

resource "aws_route" "egress_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

/*
 * Create NAT gateway and allocate Elastic IP for it
 */
resource "aws_eip" "gateway_eip" {
  tags = {
    Name = "eip-${var.network_name}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name     = "nat-${var.network_name}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, each.value[0], each.value[1])

  tags = {
    Name = format("%s-%s-%s",
      var.network_name,
      "privates",
      element(split("-", each.key), length(split("-", each.key)) - 1)
    )
    Usage                                                = "privates"
    format("kubernetes.io/cluster/%s", var.network_name) = "shared"
    "kubernetes.io/role/internal-elb"                    = 1
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s-%s", var.network_name, "private")
  }
}

resource "aws_route_table_association" "private_rta" {
  for_each = aws_subnet.private_subnets

  route_table_id = aws_route_table.private_rt.id
  subnet_id      = each.value.id
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = var.destinationCIDRblock
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# SECURITY
resource "aws_network_acl" "vpc_security_acl" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.all_subnets.ids
  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.ingressCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.ingressCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.ingressCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress port 22
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.egressCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.egressCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.egressCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

  tags         = local.tags
}
