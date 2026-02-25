resource "aws_iam_role" "eks_admin" {
  name = var.eks_admin_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.eks_admin_account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

