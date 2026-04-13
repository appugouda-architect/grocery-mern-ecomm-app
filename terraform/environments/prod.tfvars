environment = "prod"
aws_region  = "us-east-1"
node_env    = "production"

# VPC — separate CIDR from dev to allow future VPC peering if needed
vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]

# ECR
ecr_image_retention_count = 20

# ECS — larger sizing for prod
backend_cpu     = 512
backend_memory  = 1024
frontend_cpu    = 256
frontend_memory = 512

backend_desired_count  = 2
frontend_desired_count = 2
backend_min_capacity   = 2
backend_max_capacity   = 6
frontend_min_capacity  = 2
frontend_max_capacity  = 4

# App config — replace with your production domain
allowed_origins = "https://yourdomain.com,https://www.yourdomain.com"

# Secrets
create_secret_shells = true

# Replace with your ACM certificate ARN for HTTPS
acm_certificate_arn = "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID"
