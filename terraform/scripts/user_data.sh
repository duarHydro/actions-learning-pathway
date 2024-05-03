#!/bin/bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 818836127373.dkr.ecr.eu-west-1.amazonaws.com
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config

