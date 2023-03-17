### EC2 Instance SG
resource "aws_security_group" "consumer1-ec2-web-sg" {
  name = "${var.environment-consumer1}-ec2-web-sg"
  vpc_id = aws_vpc.consumer1-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = ["pl-0721453c7ac4ec009"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### EC2 Instance SG
resource "aws_security_group" "consumer2-ec2-web-sg" {
  name = "${var.environment-consumer2}-ec2-web-sg"
  vpc_id = aws_vpc.consumer2-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = ["pl-0721453c7ac4ec009"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### ECS SG
resource "aws_security_group" "consumer2-ecs-web-sg" {
  name = "${var.environment-consumer2}-ecs-web-sg"
  vpc_id = aws_vpc.consumer2-vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### EC2 Instance SG
resource "aws_security_group" "consumer3-ec2-web-sg" {
  name = "${var.environment-consumer3}-ec2-web-sg"
  vpc_id = aws_vpc.consumer3-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    prefix_list_ids = ["pl-0721453c7ac4ec009"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}