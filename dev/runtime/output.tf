output "docker_repository_worker_endpoint" {
  value = aws_ecr_repository.repository.repository_url
}
output "runtime_security_id" {
  value = aws_security_group.ecs_sg.id
}