terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags { tags = { Project = "laravel-app", Environment = var.environment, ManagedBy = "terraform" } }
}

module "networking" {
  source           = "../../modules/networking"
  name             = var.name
  vpc_cidr         = var.vpc_cidr
  application_port = 80
}

module "storage_secrets" {
  source              = "../../modules/storage_secrets"
  name                = var.name
  uploads_bucket_name = "${var.name}-${var.aws_account_id}-uploads"
}

module "database" {
  source                  = "../../modules/database"
  name                    = var.name
  private_subnet_ids      = module.networking.private_subnet_ids
  security_group_id       = module.networking.database_security_group_id
  instance_class          = var.rds_instance_class
  multi_az                = true
  backup_retention_period = 14
  deletion_protection     = true
  skip_final_snapshot     = false
}

module "compute" {
  source                        = "../../modules/compute"
  name                          = var.name
  aws_region                    = var.aws_region
  vpc_id                        = module.networking.vpc_id
  public_subnet_ids             = module.networking.public_subnet_ids
  private_subnet_ids            = module.networking.private_subnet_ids
  alb_security_group_id         = module.networking.alb_security_group_id
  application_security_group_id = module.networking.application_security_group_id
  instance_type                 = var.ec2_instance_type
  desired_capacity              = 2
  min_size                      = 2
  max_size                      = 4
  image_uris                    = { backend = var.backend_image_uri, frontend = var.frontend_image_uri }
  database_host                 = module.database.rds_endpoint
  database_secret_arn           = module.database.rds_secret_arn
  application_secret_arn        = module.storage_secrets.application_secret_arn
  redis_host                    = module.database.redis_endpoint
  uploads_bucket_name           = module.storage_secrets.uploads_bucket_name
  uploads_bucket_arn            = module.storage_secrets.uploads_bucket_arn
  cicd_artifacts_bucket_arn     = "arn:aws:s3:::${var.name}-cicd-artifacts"
}

module "cicd_pipeline" {
  source                  = "../../modules/cicd_pipeline"
  name                    = var.name
  aws_region              = var.aws_region
  github_owner            = var.github_owner
  github_repositories     = var.github_repositories
  autoscaling_group_names = module.compute.autoscaling_group_names
  target_group_names      = module.compute.target_group_names
}

module "monitoring" {
  source                          = "../../modules/monitoring"
  name                            = var.name
  alert_email                     = var.alert_email
  alb_arn_suffix                  = module.compute.alb_arn_suffix
  backend_target_group_arn_suffix = module.compute.backend_target_group_arn_suffix
  autoscaling_group_names         = module.compute.autoscaling_group_names
}

output "alb_dns_name" { value = module.compute.alb_dns_name }
output "ecr_repository_urls" { value = module.cicd_pipeline.repository_urls }
