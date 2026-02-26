#all security groups are created by the EKS module, we adjust their rules here.

# Allow HTTP (port 80) ingress for ALB
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_security_group_id
  description       = "Allow HTTP traffic from ALB"
}

# Allow HTTPS (port 443) ingress for ALB
resource "aws_security_group_rule" "allow_https_inbound" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_security_group_id
  description       = "Allow HTTPS traffic from ALB"
}

# Allow HTTP (port 80) from cluster SG to node SG for ALB -> Pods communication
resource "aws_security_group_rule" "allow_http_from_cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = module.eks.node_security_group_id
  description              = "Allow HTTP from ALB (cluster SG) to nodes for pod access"
}

# Allow HTTP (port 80) egress from cluster SG to node SG for ALB -> Pods communication
resource "aws_security_group_rule" "allow_http_egress_from_cluster_to_nodes" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = module.eks.cluster_security_group_id
  description              = "Allow HTTP egress from ALB (cluster SG) to nodes for pod access"
}