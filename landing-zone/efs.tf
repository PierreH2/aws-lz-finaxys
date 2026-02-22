# EFS pour stockage persistant des workloads EKS Fargate
resource "aws_security_group" "efs" {
  name        = "${var.efs_name}-sg"
  description = "Allow NFS traffic for EFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.efs_name}-sg"
  }
}

resource "aws_efs_file_system" "app_data" {
  creation_token = var.efs_name

  tags = {
    Name = var.efs_name
  }
}

resource "aws_efs_mount_target" "app_data" {
  count           = length(module.vpc.private_subnets)
  file_system_id  = aws_efs_file_system.app_data.id
  subnet_id       = module.vpc.private_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}
