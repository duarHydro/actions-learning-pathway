resource "aws_ecs_cluster" "mqtt_server_cluster" {
  name = "mqtt-server-cluster"

  tags = {
    Name = "mqtt-server-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "mqtt_server_cluster" {
  cluster_name       = aws_ecs_cluster.mqtt_server_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.mqtt_server_spot.name, aws_ecs_capacity_provider.mqtt_server_ondemand.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.mqtt_server_spot.name
    weight            = 1
    base              = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.mqtt_server_ondemand.name
    weight            = 0
    base              = 0
  }
}

resource "aws_ecs_service" "mqtt_server_service" {
  name            = "mqtt-server-service"
  cluster         = aws_ecs_cluster.mqtt_server_cluster.id
  task_definition = aws_ecs_task_definition.mqtt_server_task.arn
  desired_count   = 1

  network_configuration {
    subnets         = data.terraform_remote_state.cloudicity_core.outputs.subnet_private_ids
    security_groups = [data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mqtt_server_tg.arn
    container_name   = "mqtt-server-container"
    container_port   = 1883
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mqtt_server_tg_health.arn
    container_name   = "mqtt-server-container"
    container_port   = 8888
  }

  force_new_deployment = true

  triggers = {
    redeployment = timestamp()
  }

  # we put this dependency because we need the listener to be
  # created before the service and it's not implicit in the code
  depends_on = [
    aws_lb_listener.mqtt_server_listener
  ]

  tags = {
    Name = "mqtt-server-service"
  }
}

resource "aws_ecs_task_definition" "mqtt_server_task" {
  family             = "mqtt-server-task"
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = data.terraform_remote_state.cloudicity_core.outputs.iam_role_ecs_task_execution_arn
  network_mode       = "awsvpc"
  cpu                = "2000"
  memory             = "1800"

  container_definitions = jsonencode([
    {
      "name" : "mqtt-server-container",
      "image" : "${var.mqtt_server_image}",
      "portMappings" : [
        {
          "containerPort" : 1883,
          "hostPort" : 1883,
          "protocol" : "tcp"
        },
        {
          "containerPort" : 8888,
          "hostPort" : 8888,
          "protocol" : "tcp"
        }
      ],
      "essential" : true,
      "memory" : 900, # about 95% of 1GB
      "cpu" : 950,    # about 95% of 1 vCPU
      "environment" : [
        {
          "name" : "DOCKER_VERNEMQ_LISTENER__TCP__PROXY_PROTOCOL",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_ALLOW_ANONYMOUS",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_ALLOW_REGISTER_DURING_NETSPLIT",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_ALLOW_PUBLISH_DURING_NETSPLIT",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_ALLOW_SUBSCRIBE_DURING_NETSPLIT",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_ALLOW_UNSUBSCRIBE_DURING_NETSPLIT",
          "value" : "on"
        },
        {
          "name" : "DOCKER_VERNEMQ_LISTENER__TCP__proxy_protocol_use_cn_as_username",
          "value" : "on"
        }
      ]
    }
  ])
}

resource "aws_ecs_capacity_provider" "mqtt_server_spot" {
  name = "mqtt-server-spot"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.mqtt_server_spot.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }
  }
}

resource "aws_ecs_capacity_provider" "mqtt_server_ondemand" {
  name = "mqtt-server-ondemand"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.mqtt_server_ondemand.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 100
    }
  }
}

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

data "template_file" "user_data" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.mqtt_server_cluster.name
  }
}

resource "aws_launch_template" "mqtt_server_spot" {
  name_prefix   = "mqtt-server-spot"
  image_id      = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type = "t3.small"

  iam_instance_profile {
    name = data.terraform_remote_state.cloudicity_core.outputs.iam_instance_profile_ecs_instance_name
  }

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price          = "0.022"
      spot_instance_type = "one-time"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    security_groups = [data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id]
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_launch_template" "mqtt_server_ondemand" {
  name_prefix   = "mqtt-server-ondemand"
  image_id      = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type = "t3.small"

  iam_instance_profile {
    name = data.terraform_remote_state.cloudicity_core.outputs.iam_instance_profile_ecs_instance_name
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    security_groups = [data.terraform_remote_state.cloudicity_core.outputs.aws_security_group_mqtt_server_sg_id]
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_autoscaling_group" "mqtt_server_spot" {
  name                      = "mqtt-server-spot"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  vpc_zone_identifier       = data.terraform_remote_state.cloudicity_core.outputs.subnet_private_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.mqtt_server_spot.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mqtt-server-spot"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "mqtt_server_ondemand" {
  name                      = "mqtt-server-ondemand"
  desired_capacity          = 0
  max_size                  = 1
  min_size                  = 0
  vpc_zone_identifier       = data.terraform_remote_state.cloudicity_core.outputs.subnet_private_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.mqtt_server_ondemand.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "mqtt-server-spot"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}
