resource "aws_lb" "nlb" {
  for_each = aws_autoscaling_group.this

  name               = "${each.key}-delib-pract"
  internal           = false
  load_balancer_type = "network"
  enable_deletion_protection = false

  subnet_mapping {
    subnet_id = aws_subnet.this.id
  }

  tags = {
    Name = "${each.key}-delib-pract"
  }
}

resource "aws_lb_target_group" "tg_https" {
  for_each = aws_lb.nlb

  name        = "${each.key}-tg-https"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    port               = "443"
    protocol           = "TCP"
    interval           = 30
    timeout            = 10
    healthy_threshold  = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "tg_ssh" {
  for_each = aws_lb.nlb

  name        = "${each.key}-tg-ssh"
  port        = 22
  protocol    = "TCP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    port               = "22"
    protocol           = "TCP"
    interval           = 30
    timeout            = 10
    healthy_threshold  = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "listener_https" {
  for_each = aws_lb_target_group.tg_https

  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_lb_listener" "listener_ssh" {
  for_each = aws_lb_target_group.tg_ssh

  load_balancer_arn = aws_lb.nlb[each.key].arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_autoscaling_attachment" "asg_https_attachment" {
  for_each = aws_autoscaling_group.this

  autoscaling_group_name = each.value.name
  lb_target_group_arn    = aws_lb_target_group.tg_https[each.key].arn
}

resource "aws_autoscaling_attachment" "asg_ssh_attachment" {
  for_each = aws_autoscaling_group.this

  autoscaling_group_name = each.value.name
  lb_target_group_arn    = aws_lb_target_group.tg_ssh[each.key].arn
}
