resource "aws_security_group" "stepstone" {
  name        = "stepstone"
  description = "stepstone"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egressCIDRblock]
  }

  tags = {
    Usage = "stepstone"
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "ssh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.egressCIDRblock]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egressCIDRblock]
  }

  tags = {
    Usage = "ssh"
  }
}

resource "aws_instance" "stepstone" {
  lifecycle {
    ignore_changes = [
      user_data,
      associate_public_ip_address
    ]
  }

  ami                                  = data.aws_ami.aws_linux.id
  instance_type                        = "t3.medium"
  subnet_id                            = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id
  ebs_optimized                        = true
  associate_public_ip_address          = true
  source_dest_check                    = false
  instance_initiated_shutdown_behavior = "stop"

  vpc_security_group_ids = [
    aws_security_group.ssh.id,
    aws_security_group.stepstone.id
  ]

  tags = {
    Name        = "stepstone"
    Environment = terraform.workspace
    Terraform   = true
  }
}
