### EC2 Instance role and profile - permissions to check into SSM
resource "aws_iam_role" "web-ec2-role" {
  name                = "${var.environment-consumer1}-ec2-web-role"
  assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}
data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_instance_profile" "web-ec2-instance-profile" {
name = "web-ec2-profile"
role = aws_iam_role.web-ec2-role.name
}

### ECS Role to launch
resource "aws_iam_role" "consumer2-ecs-agent" {
  name               = "${var.environment-consumer2}-ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.consumer2-ecs-agent.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"]
}
resource "aws_iam_instance_profile" "consumer2-ecs-instance-profile" {
  name = "${var.environment-consumer2}-ecs-agent"
  role = aws_iam_role.consumer2-ecs-agent.id
}


### ECK Role to launch
resource "aws_iam_role" "consumer3-eks" {
  name               = "${var.environment-consumer3}-eks"
  assume_role_policy = data.aws_iam_policy_document.consumer3-eks.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}


### ECK Role for nodes
resource "aws_iam_role" "consumer3-nodes" {
  name = "${var.environment-consumer3}-eks-nodes"
  assume_role_policy = data.aws_iam_policy_document.consumer3-eks-nodes.json
}

resource "aws_iam_role_policy_attachment" "amazon-eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.consumer3-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.consumer3-nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon-ec2-container-registry-read-only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.consumer3-nodes.name
}