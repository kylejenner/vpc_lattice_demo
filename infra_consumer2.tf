#Create consumer2 VPC with no direct internet path
resource "aws_vpc" "consumer2-vpc" {
  provider             = aws.consumer2
  cidr_block           = var.vpc-cidr-consumer2
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment-consumer2}-vpc"
  }
}
resource "aws_subnet" "consumer2-subnet-priv" {
 count      = length(var.subnet-priv-consumer2)
 vpc_id     = aws_vpc.consumer2-vpc.id
 cidr_block = element(var.subnet-priv-consumer2, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "${var.environment-consumer2}-subnet-priv-${count.index + 1}"
 }
}
resource "aws_route_table" "consumer2-rt-priv-1" {
  provider = aws.consumer2
  vpc_id   = aws_vpc.consumer2-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.central-tgw.id
  }   
  tags = {
    Name = "${var.environment-consumer2}-priv-rt-1"
  }
}
resource "aws_route_table_association" "consumer2-private-subnet-asso" {
 count = length(var.subnet-priv-consumer2)
 subnet_id      = element(aws_subnet.consumer2-subnet-priv[*].id, count.index)
 route_table_id = aws_route_table.consumer2-rt-priv-1.id
}


resource "aws_alb" "consumer2-web-alb" {
  name               = "${var.environment-consumer2}-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.consumer2-subnet-priv[0].id}", "${aws_subnet.consumer2-subnet-priv[1].id}"]
  security_groups    = [aws_security_group.consumer2-ecs-web-sg.id]

  tags = {
    Name = "${var.environment-consumer2}-alb"
  }
}

### ALB to be used with ECS
resource "aws_alb_target_group" "consumer2-web-tg" {
  name     = "${var.environment-consumer2}-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.consumer2-vpc.id
}

resource "aws_alb_listener" "web-listeners" {
  load_balancer_arn = aws_alb.consumer2-web-alb.arn
  port              = "8080"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.consumer2-web-tg.arn
  }
}

### EC2 Instance launch config to be used with ECS
resource "aws_launch_configuration" "consumer2-ecs-launch-config" {
    name_prefix          = "${var.environment-consumer2}-launch-config"  
    image_id             = data.aws_ami.ecs.id
    iam_instance_profile = aws_iam_instance_profile.consumer2-ecs-instance-profile.id
    security_groups      = [aws_security_group.consumer2-ecs-web-sg.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=consumer2-ecs-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t3.small"
}

resource "aws_autoscaling_group" "consumer2-ecs-asg" {
    provider                  = aws.consumer2
    name_prefix               = "${var.environment-consumer2}-asg"
    vpc_zone_identifier       = ["${aws_subnet.consumer2-subnet-priv[0].id}","${aws_subnet.consumer2-subnet-priv[1].id}"]
    launch_configuration      = aws_launch_configuration.consumer2-ecs-launch-config.name

    desired_capacity          = 1
    min_size                  = 1
    max_size                  = 1
    health_check_grace_period = 300
    health_check_type         = "EC2"

      tag {
    key                 = "Name"
    value               = "${var.environment-consumer2}-ecs-cluster"
    propagate_at_launch = true
  }
    lifecycle {
    create_before_destroy = true
  }
}
