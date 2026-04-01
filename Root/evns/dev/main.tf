
# ─────────────────────────────
# VPC
# ─────────────────────────────

module "vpc" {
  source   = "../../modules/infrastructure"
aws_region = var.region
vpc_cidr = var.vpc_cidr
vpc_name = "prod-vpc"
public_subnet_1_cidr = var.public_subnet_1_cidr
public_subnet_2_cidr = var.public_subnet_2_cidr
private_subnet_1_cidr = var.private_subnet_1_cidr
private_subnet_2_cidr = var.private_subnet_2_cidr
private_subnet_3_cidr = var.private_subnet_3_cidr
private_subnet_4_cidr = var.private_subnet_4_cidr
private_subnet_5_cidr = var.private_subnet_5_cidr
private_subnet_6_cidr = var.private_subnet_6_cidr
availability_zone_1a = var.availability_zone-1a
availability_zone_1b = var.availability_zone-1b
vpc_id            = module.vpc.vpc_id
 allowed_ssh_cidr = ["0.0.0.0/0"]   
}


# ────────────────────────────
# frontend ec2 instance public
# ─────────────────────────────
module "frontend-ec2" {
source = "../../modules/frontend/ec2"
aws_region = var.region
ami = var.ami
instance_type = var.instance_type
key_name = var.key_name
subnet_id = module.vpc.public_subnets[0]
security_group_id = module.vpc.bastion_sg_id

}

# ────────────────────────────
# backend ec2 instance public
# ─────────────────────────────
module "backend-ec2" {
source = "../../modules/backend/ec2"
aws_region = var.region
ami = var.ami
instance_type = var.instance_type
key_name = var.key_name
subnet_id = module.vpc.public_subnets[0]
security_group_id = module.vpc.bastion_sg_id

}
# ────────────────────────────
# AWS Bastion Host
# ─────────────────────────────
module "bastion" {
source = "../../modules/bastion"
aws_region = var.region
ami = var.ami
instance_type = var.instance_type
key_name = var.key_name
subnet_id = module.vpc.public_subnets[0]
security_group_id = module.vpc.bastion_sg_id

}

# ─────────────────────────────
# Frontend ALB
# ─────────────────────────────
module "frontend_alb" {
source = "../../modules/frontend/loadbalancer-frontend"
aws_region = var.region
vpc_id = module.vpc.vpc_id
subnets = module.vpc.public_subnets
security_group_id = module.vpc.alb_frontend_sg_id
alb_name = "frontend-alb"
target_group_name = "frontend-tg"

}

# ─────────────────────────────
# Backend ALB
# ─────────────────────────────
module "backend_alb" {
source = "../../modules/backend/loadbalancer-backend"
aws_region = var.region
vpc_id = module.vpc.vpc_id
subnets = module.vpc.public_subnets
security_group_id = module.vpc.alb_backend_sg_id
alb_name = "backend-alb"
target_group_name = "backend-tg"
}


# ─────────────────────────────
# RDS (DB Tier)
# ─────────────────────────────
module "rds" {
source         = "../../modules/database"
aws_region   = var.region
project_name = "three-tier"
identifier   = "book-rds"
allocated_storage = 20
engine            = "mysql"
engine_version    = "8.0"
instance_class    = var.instance_class
multi_az          = false
db_name           = "bookdb"
db_username       = var.db_username
db_password       = var.db_password
db_subnet_1_id    = module.vpc.private_db_subnets[0]
db_subnet_2_id    = module.vpc.private_db_subnets[1]
rds_sg_id         = module.vpc.database_sg_id

}



# ─────────────────────────────
# Frontend Launch Template
# ─────────────────────────────
module "frontend_launchtemplate" {

source        = "../../modules/frontend/launch-template"
#source = "../../modules/frontend/launch-template"
aws_region   = var.region
project_name   = "three-tier"
#frontend_ami   = module.frontend_launchtemplate.ami.id
instance_type  = var.instance_type
frontend_sg_id = module.vpc.frontend_server_sg_id
key_name       = var.key_name
instanceid = module.frontend-ec2.frontend_instanceid

}
# ─────────────────────────────
# Backend Launch Template
# ─────────────────────────────
module "backend_launchtemplate" {

source        = "../../modules/backend/launch-template"
#source = "../../modules/backend/launch-template"
aws_region   = var.region
project_name   = "three-tier"
#backend_ami    = module.backend_launchtemplate.ami.id
instance_type  = var.instance_type
backend_sg_id  = module.vpc.backend_server_sg_id
key_name       = var.key_name
instanceid = module.backend-ec2.backend_instanceid

}

# ────────────────────────────
# Auto Scaling Group backend
# ─────────────────────────────

module "asg-backend" {
source     = "../../modules/backend/asg"
#source = "../../modules/backend/asg"
aws_region = var.region
project_name = "books-three-tier"


# Backend
backend_launch_template_id = module.backend_launchtemplate.backend_launch_template_id
app_subnet_1_id            = module.vpc.private_app_subnets[0]
app_subnet_2_id            = module.vpc.private_app_subnets[1]
backend_target_group_arn   = module.backend_alb.alb_target_group_arn
backend_desired_capacity = 1
backend_min_size         = 1
backend_max_size         = 3
# Scaling
scale_out_target_value = 80

}

# ────────────────────────────
# Auto Scaling Group frontend
# ─────────────────────────────

module "asg-frontend" {
source     = "../../modules/frontend/asg"
# source = "../../modules/frontend/asg"
aws_region = var.region
project_name = "books-three-tier"

# Frontend
frontend_launch_template_id = module.frontend_launchtemplate.frontend_launch_template_id
web_subnet_1_id             = module.vpc.public_subnets[0]
web_subnet_2_id             = module.vpc.public_subnets[1]
frontend_target_group_arn   = module.frontend_alb.alb_target_group_arn

frontend_desired_capacity = 1
frontend_min_size         = 1
frontend_max_size         = 3

# Scaling
scale_out_target_value = 80

}