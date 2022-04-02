#
# ECR repo
#

resource "aws_ecr_repository" "ecr_repo" {
  name                 = var.prefix
  image_tag_mutability = "MUTABLE"
}