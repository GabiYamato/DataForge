terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  backend "s3" {
    bucket = var.state_bucket
    key    = "terraform/state/dataforge.tfstate"
    region = var.aws_region
    dynamodb_table = var.state_lock_table
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  name_prefix         = var.name_prefix
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "storage" {
  source = "./modules/storage"

  name_prefix        = var.name_prefix
  deployment_suffix  = var.deployment_suffix
  logging_bucket_arn = var.logging_bucket_arn
}

module "kafka" {
  source = "./modules/kafka"

  name_prefix           = var.name_prefix
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  kafka_version         = var.kafka_version
  broker_instance_type  = var.kafka_broker_instance_type
  num_broker_nodes      = var.kafka_broker_count
  security_group_id     = module.networking.kafka_security_group_id
}

module "glue" {
  source = "./modules/glue"

  name_prefix        = var.name_prefix
  s3_bronze_bucket   = module.storage.bronze_bucket_id
  s3_silver_bucket   = module.storage.silver_bucket_id
  s3_gold_bucket     = module.storage.gold_bucket_id
}

module "lambda" {
  source = "./modules/lambda"

  name_prefix                 = var.name_prefix
  subnet_ids                  = module.networking.private_subnet_ids
  security_group_id           = module.networking.lambda_security_group_id
  ingestion_bucket_arn        = module.storage.landing_bucket_arn
  bronze_bucket_arn           = module.storage.bronze_bucket_arn
  kafka_bootstrap_brokers     = module.kafka.bootstrap_brokers
  kafka_cluster_arn           = module.kafka.cluster_arn
  kafka_topics                = var.kafka_topics
  glue_catalog_database_name  = module.glue.catalog_database_name
  ingestion_package_path      = var.ingestion_lambda_package
  api_package_path            = var.api_lambda_package
}

module "api_gateway" {
  source = "./modules/api_gateway"

  name_prefix          = var.name_prefix
  lambda_invoke_arn    = module.lambda.api_lambda_invoke_arn
  lambda_function_name = module.lambda.api_lambda_function_name
}
