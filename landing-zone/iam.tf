# IAM user for CI/CD (optional)
resource "aws_iam_user" "cicd" {
  name = "agentic-research-cicd"
}
resource "aws_iam_user_policy_attachment" "cicd_ecr" {
  user       = aws_iam_user.cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_user_policy_attachment" "cicd_eks" {
  user       = aws_iam_user.cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
