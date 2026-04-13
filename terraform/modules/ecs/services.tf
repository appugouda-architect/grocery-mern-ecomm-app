# ── ECS Cluster ───────────────────────────────────────────────────────────────
resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { Name = "${var.name_prefix}-cluster" }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1  # at least 1 task always on stable FARGATE, not SPOT
  }
}

# ── Backend Service ───────────────────────────────────────────────────────────
resource "aws_ecs_service" "backend" {
  name                              = "${var.name_prefix}-backend"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.backend.arn
  desired_count                     = var.backend_desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 60  # time for Node.js to connect to MongoDB Atlas

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.backend_sg_id]
    assign_public_ip = false  # NAT Gateway handles outbound; no public IP needed
  }

  load_balancer {
    target_group_arn = var.backend_tg_arn
    container_name   = "backend"
    container_port   = var.backend_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true  # auto-rollback if new deployment fails health checks
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    # Ignore desired_count: let autoscaling manage it without Terraform interference.
    # Ignore task_definition: let CI/CD push new image tags without Terraform.
    ignore_changes = [desired_count, task_definition]
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_managed]

  tags = { Name = "${var.name_prefix}-backend-service" }
}

# ── Frontend Service ──────────────────────────────────────────────────────────
resource "aws_ecs_service" "frontend" {
  name                              = "${var.name_prefix}-frontend"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.frontend.arn
  desired_count                     = var.frontend_desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 30

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.frontend_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_tg_arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_managed]

  tags = { Name = "${var.name_prefix}-frontend-service" }
}
