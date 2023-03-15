### ECS cluster
resource "aws_ecs_cluster" "consumer2-ecs-cluster" {
  name = "${var.environment-consumer2}-ecs-cluster"
}

### ECS Service
resource "aws_ecs_service" "consumer2-ecs-service" {
  name            = "${var.environment-consumer2}-ecs-service"
  cluster         = "${aws_ecs_cluster.consumer2-ecs-cluster.id}"
  task_definition = "${aws_ecs_task_definition.consumer2-ecs-task.id}"
  desired_count   = 1
  launch_type     = "EC2" # valid values are EC2 and FARGATE

  load_balancer {
    target_group_arn = aws_alb_target_group.consumer2-web-tg.arn
    container_name   = aws_ecs_task_definition.consumer2-ecs-task.family
    container_port   = 8080
  }
  network_configuration {
    subnets            = ["${aws_subnet.consumer2-subnet-priv[0].id}", "${aws_subnet.consumer2-subnet-priv[1].id}"]
    security_groups    = [aws_security_group.consumer2-ecs-web-sg.id]
  }
}

### ECS Task
resource "aws_ecs_task_definition" "consumer2-ecs-task" {
family          = "consumer2-app"
network_mode    = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "1024"
  cpu                      = "512"
  container_definitions = jsonencode([
    {
      name      = "consumer2-app"
      image     = "123456789.dkr.ecr.us-west-2.amazonaws.com/consumer2-repo"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    },
      ])
}