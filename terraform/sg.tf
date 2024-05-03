resource "aws_security_group_rule" "mqtt_server_mqtt_ingress_rule" {
  type              = "ingress"
  from_port         = 1883
  to_port           = 1883
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "mqtt protocol"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_mqtts_ingress_rule" {
  type              = "ingress"
  from_port         = 8883
  to_port           = 8883
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "mqtts protocol"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_websocket_ingress_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "websocket"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_secure_websocket_ingress_rule" {
  type              = "ingress"
  from_port         = 8430
  to_port           = 8430
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "secure websocket"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_http_ingress_rule" {
  type              = "ingress"
  from_port         = 8888
  to_port           = 8888
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "HTTP Listener"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_epmd_ingress_rule" {
  type              = "ingress"
  from_port         = 4369
  to_port           = 4369
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "epmd (clustering)"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_internal_mqtt_ingress_rule" {
  type              = "ingress"
  from_port         = 44053
  to_port           = 44053
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "internal mqtt messages (clustering)"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_erland_ingress_rule" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id
  description       = "erland ports (clustering)"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_server_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_lb_mqtt_ingress_rule" {
  type              = "ingress"
  from_port         = 1883
  to_port           = 1883
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_lb_sg_id
  description       = "mqtt protocol"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_lb_mqtts_ingress_rule" {
  type              = "ingress"
  from_port         = 8883
  to_port           = 8883
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_lb_sg_id
  description       = "mqtts protocol"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mqtt_lb_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_lb_sg_id
  description       = "Allow all outbound traffic"

  cidr_blocks = ["0.0.0.0/0"]
}
