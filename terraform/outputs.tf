output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "Point your DNS CNAME (or A alias) to this value to access the app"
}

output "backend_ecr_repo_url" {
  value       = module.ecr.backend_repo_url
  description = "Push backend Docker image here"
}

output "frontend_ecr_repo_url" {
  value       = module.ecr.frontend_repo_url
  description = "Push frontend Docker image here"
}

output "backend_log_group" {
  value       = "/ecs/${var.app_name}-${var.environment}/backend"
  description = "CloudWatch log group for backend service"
}

output "frontend_log_group" {
  value       = "/ecs/${var.app_name}-${var.environment}/frontend"
  description = "CloudWatch log group for frontend service"
}

output "secret_arn" {
  value       = module.secrets.secret_arn
  description = "Secrets Manager ARN — populate real values here before first deploy"
  sensitive   = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "nat_gateway_ips" {
  value       = module.vpc.nat_gateway_ips
  description = "Add these IPs to MongoDB Atlas IP Access List"
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
