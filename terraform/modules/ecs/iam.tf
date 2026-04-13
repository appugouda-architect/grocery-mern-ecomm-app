# ── ECS Task Execution Role ───────────────────────────────────────────────────
# Used by the ECS AGENT (not your app code) to:
#   - Pull images from ECR
#   - Send logs to CloudWatch
#   - Inject secrets from Secrets Manager at task startup
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.name_prefix}-ecs-execution-role" }
}

# Grants ECR pull + CloudWatch log stream creation
resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow reading the app secrets at container startup
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "${var.name_prefix}-execution-secrets-policy"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.secret_arn]
    }]
  })
}

# ── ECS Task Role ─────────────────────────────────────────────────────────────
# Used by your APPLICATION CODE at runtime.
# The app currently only calls external HTTPS services (MongoDB Atlas, Cloudinary),
# so this role needs no AWS permissions. Add policies here when you add S3, SES, etc.
resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.name_prefix}-ecs-task-role" }
}
