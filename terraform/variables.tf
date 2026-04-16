# ── Core ──────────────────────────────────────────────────────────────────────
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment: dev or prod"
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "app_name" {
  type    = string
  default = "grocery-mern-app"
}

# ── VPC ───────────────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AZs to deploy into (minimum 2)"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (one per AZ)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets (one per AZ)"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

}

# ── ECR ───────────────────────────────────────────────────────────────────────
variable "ecr_image_retention_count" {
  type    = number
  default = 10
}

# ── ECS ───────────────────────────────────────────────────────────────────────
variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "backend_cpu" {
  type        = number
  description = "Fargate CPU units for backend (256, 512, 1024, 2048, 4096)"
  default     = 256
}

variable "backend_memory" {
  type        = number
  description = "Fargate memory MiB for backend"
  default     = 512
}

variable "frontend_cpu" {
  type        = number
  description = "Fargate CPU units for frontend"
  default     = 256
}

variable "frontend_memory" {
  type        = number
  description = "Fargate memory MiB for frontend"
  default     = 512
}

variable "backend_desired_count" {
  type    = number
  default = 1
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "backend_min_capacity" {
  type    = number
  default = 1
}

variable "backend_max_capacity" {
  type    = number
  default = 2
}

variable "frontend_min_capacity" {
  type    = number
  default = 1
}

variable "frontend_max_capacity" {
  type    = number
  default = 2
}

# ── Networking ────────────────────────────────────────────────────────────────
variable "backend_port" {
  type    = number
  default = 9000
}

variable "frontend_port" {
  type    = number
  default = 80
}

# ── App Config ────────────────────────────────────────────────────────────────
variable "node_env" {
  type        = string
  description = "NODE_ENV value (development or production)"
  default     = "development"
}

variable "allowed_origins" {
  type        = string
  description = "Comma-separated list of allowed CORS origins (e.g. https://yourdomain.com)"
  default     = "*"
}

# ── Secrets ───────────────────────────────────────────────────────────────────
variable "create_secret_shells" {
  type        = bool
  default     = true
  description = "Create Secrets Manager secret shells with placeholder values"
}

# ── ACM Certificate (optional, set to enable HTTPS) ──────────────────────────
variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of ACM certificate for HTTPS. Leave empty to use HTTP only."
}
