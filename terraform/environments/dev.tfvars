environment = "dev"
aws_region  = "us-east-1"
node_env    = "development"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# ECR
ecr_image_retention_count = 5

# ECS — small sizing for dev
backend_cpu     = 256
backend_memory  = 512
frontend_cpu    = 256
frontend_memory = 512

backend_desired_count  = 1
frontend_desired_count = 1
backend_min_capacity   = 1
backend_max_capacity   = 1
frontend_min_capacity  = 1
frontend_max_capacity  = 1

# App config — update allowed_origins to your dev domain or ALB DNS name
allowed_origins = "http://localhost:5173,http://localhost:8080,http://grocery-mern-app-dev-alb-560863399.us-east-1.elb.amazonaws.com"

# Secrets
create_secret_shells = true

# Leave empty to use HTTP only (no TLS) during initial setup.
# Set to ACM cert ARN once you have a domain: acm_certificate_arn = "arn:aws:acm:..."
acm_certificate_arn = ""
