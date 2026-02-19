# Network Load Balancer (NLB)
resource "aws_lb" "eks_nlb" {
  name               = var.nlb_name
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.app_lb.id]
}

resource "aws_lb_target_group" "eks_nlb_tg" {
  name        = var.nlb_tg_name
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "eks_nlb_listener" {
  load_balancer_arn = aws_lb.eks_nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks_nlb_tg.arn
  }
}
