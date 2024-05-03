resource "aws_iam_role" "ecs_task" {
  name        = "ecsTaskRole"
  description = "Allows ECS tasks to call AWS services on your behalf."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}
