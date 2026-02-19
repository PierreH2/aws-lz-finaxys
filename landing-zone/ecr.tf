# ECR
resource "aws_ecr_repository" "main" {
  name = "agentic-research"
  image_scanning_configuration {
    scan_on_push = true
  }
}
