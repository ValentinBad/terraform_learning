provider "aws" {
  region = "eu-west-2"

}

resource "random_string" "rds_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^"
  upper            = true
  lower            = true
}


resource "aws_ssm_parameter" "create_rds_password" {
  name        = "/rds/password"
  description = "RDS password"
  type        = "SecureString"
  value       = random_string.rds_password.result

}

data "aws_ssm_parameter" "rds_password" {
  name       = "/rds/password"
  depends_on = [aws_ssm_parameter.create_rds_password]
}

resource "aws_db_instance" "default" {
  identifier           = "prod-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.env == "dev" ? "db.t2.micro" : "db.t3.small"
  db_name              = "mydatabase"
  username             = "administrator"
  password             = data.aws_ssm_parameter.rds_password.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
  depends_on = [data.aws_ssm_parameter.rds_password]
}
