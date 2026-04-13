locals {
  name_prefix = "${var.app_name}-${var.environment}"
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix           = local.name_prefix
  image_retention_count = var.ecr_image_retention_count
}

module "secrets" {
  source = "./modules/secrets"

  name_prefix          = local.name_prefix
  create_secret_shells = var.create_secret_shells
}

module "security_groups" {
  source = "./modules/security_groups"

  name_prefix   = local.name_prefix
  vpc_id        = module.vpc.vpc_id
  backend_port  = var.backend_port
  frontend_port = var.frontend_port
}

module "alb" {
  source = "./modules/alb"

  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  alb_sg_id           = module.security_groups.alb_sg_id
  backend_port        = var.backend_port
  frontend_port       = var.frontend_port
  acm_certificate_arn = var.acm_certificate_arn
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix            = local.name_prefix
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  backend_sg_id          = module.security_groups.backend_ecs_sg_id
  frontend_sg_id         = module.security_groups.frontend_ecs_sg_id
  backend_tg_arn         = module.alb.backend_tg_arn
  frontend_tg_arn        = module.alb.frontend_tg_arn
  backend_ecr_repo_url   = module.ecr.backend_repo_url
  frontend_ecr_repo_url  = module.ecr.frontend_repo_url
  backend_image_tag      = var.backend_image_tag
  frontend_image_tag     = var.frontend_image_tag
  backend_cpu            = var.backend_cpu
  backend_memory         = var.backend_memory
  frontend_cpu           = var.frontend_cpu
  frontend_memory        = var.frontend_memory
  backend_desired_count  = var.backend_desired_count
  frontend_desired_count = var.frontend_desired_count
  backend_min_capacity   = var.backend_min_capacity
  backend_max_capacity   = var.backend_max_capacity
  frontend_min_capacity  = var.frontend_min_capacity
  frontend_max_capacity  = var.frontend_max_capacity
  backend_port           = var.backend_port
  frontend_port          = var.frontend_port
  node_env               = var.node_env
  allowed_origins        = var.allowed_origins
  secret_arn             = module.secrets.secret_arn
}
