# Code Commit
resource "aws_codecommit_repository" "app" {
  repository_name = local.code_commit.repository_name
  description     = "Repository for ${var.name}  application"
}