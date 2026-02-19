resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ha-lab-vpc"
  }
}

# Public Subnet - AZ1
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az1"
  }
}

# Private Subnet - AZ1
resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet-az1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ha-lab-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name = "ha-lab-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Private Subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private_rt.id
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ha-lab-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach SSM Policy
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ha-lab-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_security_group" "private_sg" {
  name   = "private-ec2-sg"
  vpc_id = aws_vpc.main.id

  # No inbound from internet
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "ha-lab-alb-sg"
  description = "Allow HTTP inbound from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ha-lab-alb-sg"
  }
}
resource "aws_lb" "app_lb" {
  name               = "ha-lab-alb"
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_az1.id,
    aws_subnet.public_az2.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "ha-lab-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "ha-lab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Public Subnet - AZ2
resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az2"
  }
}
resource "aws_route_table_association" "public_az2_assoc" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# Laucnh Template	
resource "aws_launch_template" "app_lt" {

  name_prefix   = "ha-app-"
  image_id      = "ami-019715e0d74f695be"
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              echo "<h1>HA Lab via ASG - $(hostname)</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ha-app-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 2
  vpc_zone_identifier = [
    aws_subnet.private_az1.id,
    aws_subnet.private_az2.id
  ]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  health_check_type = "ELB"
}

# New Subnet
resource "aws_subnet" "private_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-az2"
  }
}
