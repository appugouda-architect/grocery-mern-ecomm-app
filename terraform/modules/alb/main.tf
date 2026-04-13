locals {
  has_cert    = var.acm_certificate_arn != ""
  http_action = local.has_cert ? "redirect" : "forward"
}

# ── Application Load Balancer ─────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = { Name = "${var.name_prefix}-alb" }
}

# ── Target Groups ─────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "backend" {
  name        = "${var.name_prefix}-backend-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # required for Fargate

  health_check {
    enabled             = true
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = { Name = "${var.name_prefix}-backend-tg" }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.name_prefix}-frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-302"
  }

  deregistration_delay = 30

  tags = { Name = "${var.name_prefix}-frontend-tg" }
}

# ── HTTP Listener (port 80) ───────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # If cert exists: redirect HTTP → HTTPS. Otherwise forward to frontend.
  dynamic "default_action" {
    for_each = local.has_cert ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.has_cert ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.frontend.arn
    }
  }
}

# ── HTTP Listener Rules (when no cert — route /api/* to backend) ──────────────
resource "aws_lb_listener_rule" "api_http" {
  count        = local.has_cert ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern { values = ["/api", "/api/*"] }
  }
}

resource "aws_lb_listener_rule" "images_http" {
  count        = local.has_cert ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern { values = ["/images/*"] }
  }
}

# ── HTTPS Listener (port 443) — only created when ACM cert is provided ─────────
resource "aws_lb_listener" "https" {
  count = local.has_cert ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.acm_certificate_arn

  # Default: serve frontend (SPA catch-all)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ── HTTPS Listener Rules ──────────────────────────────────────────────────────
resource "aws_lb_listener_rule" "api_https" {
  count        = local.has_cert ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern { values = ["/api", "/api/*"] }
  }
}

resource "aws_lb_listener_rule" "images_https" {
  count        = local.has_cert ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern { values = ["/images/*"] }
  }
}
