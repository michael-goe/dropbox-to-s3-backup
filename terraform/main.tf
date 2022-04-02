terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

data "aws_region" "current" {}

data "aws_ssm_parameter" "dropbox_rclone_config" {
  name = var.ssm_name
}