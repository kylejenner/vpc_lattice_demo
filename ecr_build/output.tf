output "registry_id-consumer2" {
  description = "The account ID of the registry holding the repository."
  value = aws_ecr_repository.consumer2-repo.registry_id
}
output "repository_url-consumer2" {
  description = "The URL of the repository."
  value = aws_ecr_repository.consumer2-repo.repository_url
}
output "registry_id-consumer3" {
  description = "The account ID of the registry holding the repository."
  value = aws_ecr_repository.consumer3-repo.registry_id
}
output "repository_url-consumer3" {
  description = "The URL of the repository."
  value = aws_ecr_repository.consumer3-repo.repository_url
}