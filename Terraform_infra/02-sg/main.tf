module "mysql" {
  source = "git::https://github.com/Rajeshchanti/aws_sg_modules.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "mysql"
  sg_description = "SG for mysql"
}

module "backend" {
  source = "git::https://github.com/Rajeshchanti/aws_sg_modules.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "backend"
  sg_description = "SG for backend"
}

module "frontend" {
  source = "git::https://github.com/Rajeshchanti/aws_sg_modules.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "frontend"
  sg_description = "SG for frontend"
}
module "app_alb" {
  source = "git::https://github.com/Rajeshchanti/aws_sg_modules.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "app-alb"
  sg_description = "SG for App alb"
}
module "web_alb" {
  source = "git::https://github.com/Rajeshchanti/aws_sg_modules.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "web-alb"
  sg_description = "SG for WEB alb"
}

resource "aws_security_group_rule" "mysql_backend" {
  source_security_group_id = module.backend.sg_id
  type = "ingress"
  to_port = 3306
  from_port = 3306
  protocol = "tcp"
  security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "app_alb_backend" {
  source_security_group_id = module.backend.sg_id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.app_alb.sg_id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  source_security_group_id = module.frontend.sg_id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.app_alb.sg_id
}

resource "aws_security_group_rule" "web_internet" {
  cidr_blocks = ["0.0.0.0/0"]
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.web.sg_id
}

resource "aws_security_group_rule" "internet_web_alb" {
  cidr_blocks = [ "0.0.0.0/0" ]
  type = "ingress"
  to_port = 443
  from_port = 443
  protocol = "tcp"
  security_group_id = module.web_alb.sg_id
}