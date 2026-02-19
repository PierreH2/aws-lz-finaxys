# Volumes EBS pour les PV/PVC Kubernetes
resource "aws_ebs_volume" "app_data" {
  count             = length(var.ebs_volume_names)
  availability_zone = "${var.aws_region}${element(["a","b"], count.index)}"
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  tags = {
    Name = var.ebs_volume_names[count.index]
  }
}
