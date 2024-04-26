resource "aws_lb" "mqtt_server_lb" {
  name               = "mqtt-server-lb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_lb_sg_id]
  subnets            = data.terraform_remote_state.cloudicity_core.outputs.subnet_public_ids

  tags = {
    Name = "mqtt-server-lb"
  }
}

resource "random_id" "target_group_id" {
  byte_length = 8
}

resource "aws_lb_target_group" "mqtt_server_tg" {
  name               = "mqtt-server-tg-${random_id.target_group_id.hex}"
  port               = 1883
  protocol           = "TCP"
  vpc_id             = data.terraform_remote_state.cloudicity_core.outputs.vpc_id
  target_type        = "ip"
  proxy_protocol_v2  = true
  preserve_client_ip = true

  health_check {
    enabled             = true
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  stickiness {
    type = "source_ip"
  }
}

resource "aws_lb_listener" "mqtt_server_listener" {
  load_balancer_arn = aws_lb.mqtt_server_lb.arn
  port              = 1883
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_server_tg.arn
  }
}

resource "aws_lb_target_group" "mqtt_server_tg_health" {
  name        = "mqtt-tg-health-${random_id.target_group_id.hex}"
  port        = 8888
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.cloudicity_core.outputs.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "mqtt_server_listener_health" {
  load_balancer_arn = aws_lb.mqtt_server_lb.arn
  port              = 8888
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_server_tg_health.arn
  }
}
