# ── Backend Task Definition ───────────────────────────────────────────────────
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.name_prefix}-backend"
  network_mode             = "awsvpc"  # required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.backend_ecr_repo_url}:${var.backend_image_tag}"
      essential = true

      portMappings = [{
        containerPort = var.backend_port
        protocol      = "tcp"
      }]

      # Non-sensitive config passed as plain env vars
      environment = [
        { name = "PORT",             value = tostring(var.backend_port) },
        { name = "NODE_ENV",         value = var.node_env },
        { name = "ALLOWED_ORIGINS",  value = var.allowed_origins }
      ]

      # Sensitive config injected from Secrets Manager at task startup.
      # Format: "<secret_arn>:<json_key>::"
      # The execution role must have secretsmanager:GetSecretValue on secret_arn.
      secrets = [
        { name = "MONGO_URI",               valueFrom = "${var.secret_arn}:MONGO_URI::" },
        { name = "JWT_SECRET",              valueFrom = "${var.secret_arn}:JWT_SECRET::" },
        { name = "SELLER_EMAIL",            valueFrom = "${var.secret_arn}:SELLER_EMAIL::" },
        { name = "SELLER_PASSWORD",         valueFrom = "${var.secret_arn}:SELLER_PASSWORD::" },
        { name = "CLOUDINARY_CLOUD_NAME",   valueFrom = "${var.secret_arn}:CLOUDINARY_CLOUD_NAME::" },
        { name = "CLOUDINARY_API_KEY",      valueFrom = "${var.secret_arn}:CLOUDINARY_API_KEY::" },
        { name = "CLOUDINARY_API_SECRET",   valueFrom = "${var.secret_arn}:CLOUDINARY_API_SECRET::" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:${var.backend_port}/api/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
    }
  ])

  tags = { Name = "${var.name_prefix}-backend-task" }
}

# ── Frontend Task Definition ──────────────────────────────────────────────────
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.frontend_ecr_repo_url}:${var.frontend_image_tag}"
      essential = true

      portMappings = [{
        containerPort = var.frontend_port
        protocol      = "tcp"
      }]

      # No runtime env vars needed: VITE_BACKEND_URL is baked in at image build time.
      # Build the image with: docker build --build-arg VITE_BACKEND_URL=https://yourdomain.com
      environment = []
      secrets     = []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ])

  tags = { Name = "${var.name_prefix}-frontend-task" }
}
