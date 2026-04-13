# ── ALB Security Group ────────────────────────────────────────────────────────
# Accepts inbound HTTP/HTTPS from the internet.
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP/HTTPS inbound to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound (to ECS tasks)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-alb-sg" }
}

# ── Backend ECS Security Group ────────────────────────────────────────────────
# Only accepts traffic from the ALB. Outbound to MongoDB Atlas, Cloudinary, AWS APIs.
resource "aws_security_group" "backend_ecs" {
  name        = "${var.name_prefix}-backend-ecs-sg"
  description = "Backend ECS tasks — inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB to backend port"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # HTTPS outbound: ECR, Secrets Manager, CloudWatch, MongoDB Atlas, Cloudinary
  egress {
    description = "HTTPS outbound (ECR, Secrets Manager, external APIs)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB Atlas default port (Atlas also supports 27017)
  egress {
    description = "MongoDB Atlas"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-backend-ecs-sg" }
}

# ── Frontend ECS Security Group ───────────────────────────────────────────────
# Accepts traffic from ALB on port 80. Nginx serves static files only — no backend calls.
resource "aws_security_group" "frontend_ecs" {
  name        = "${var.name_prefix}-frontend-ecs-sg"
  description = "Frontend ECS tasks — inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB to Nginx port 80"
    from_port       = var.frontend_port
    to_port         = var.frontend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # HTTPS outbound for ECR image pulls and CloudWatch logs
  egress {
    description = "HTTPS outbound (ECR, CloudWatch)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-frontend-ecs-sg" }
}
