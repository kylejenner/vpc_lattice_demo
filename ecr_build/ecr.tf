### Builds new ECR repo - build first before all infra
resource "aws_ecr_repository" "consumer2-repo" {
  provider  = aws.consumer2
  name = "consumer2-repo"
}
resource "aws_ecr_repository_policy" "consumer2-ecr-policy" {
  repository = aws_ecr_repository.consumer2-repo.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_repository" "consumer3-repo" {
  provider  = aws.consumer3
  name = "consumer3-repo"
}
resource "aws_ecr_repository_policy" "consumer3-ecr-policy" {
  repository = aws_ecr_repository.consumer3-repo.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}