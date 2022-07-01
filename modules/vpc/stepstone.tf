#Instance Role
resource "aws_iam_role" "stepstone_role" {
  name = "ssm-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name        = "stepstone"
    Environment = terraform.workspace
    Terraform   = true
  }
}

#Instance Profile
resource "aws_iam_instance_profile" "stepstone_profile" {
  name = "stepstone"
  role = aws_iam_role.stepstone_role.id
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "ssm_policy_attachment_1" {
  name       = "ssm-policy-attachment_1"
  roles      = [ aws_iam_role.stepstone_role.id ]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment_2" {
  name       = "ssm-policy-attachment_2"
  roles      = [ aws_iam_role.stepstone_role.id ]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

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
      associate_public_ip_address,
      ami
    ]
  }

  ami                                  = data.aws_ami.aws_linux.id
  instance_type                        = "t3.medium"
  subnet_id                            = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id
  ebs_optimized                        = true
  associate_public_ip_address          = true
  source_dest_check                    = false
  iam_instance_profile                 = aws_iam_instance_profile.stepstone_profile.id
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
