### EKS cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.consumer3-eks.arn

  vpc_config {
    subnet_ids = ["${aws_subnet.consumer3-subnet-priv[0].id}", "${aws_subnet.consumer3-subnet-priv[1].id}"]
  }

  depends_on = [aws_iam_role.consumer3-eks]
}

### EKS nodes
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = "consumer3-eks-cluster"
  version         = var.cluster_version
  node_group_name = "${var.environment-consumer3}-eks-nodes"
  node_role_arn   = aws_iam_role.consumer3-nodes.arn

  subnet_ids = ["${aws_subnet.consumer3-subnet-priv[0].id}", "${aws_subnet.consumer3-subnet-priv[1].id}"]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_iam_role_policy_attachment.amazon-eks-worker-node-policy,
    aws_iam_role_policy_attachment.amazon-eks-cni-policy,
    aws_iam_role_policy_attachment.amazon-ec2-container-registry-read-only,
  ]
  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}