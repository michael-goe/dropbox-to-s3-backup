#
# EFS&S3 storage
#
resource "aws_efs_file_system" "efs" {
  creation_token = "${var.prefix}-temp-storage"
  encrypted      = "true"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Name = "${var.prefix}-efs"
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.backups_subnet.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  description = "Access for the EFS file system"
  name        = "${var.prefix}-efs"
  vpc_id      = aws_vpc.backups_vpc.id

  ingress {
    from_port       = 0
    to_port         = 2049
    security_groups = [aws_security_group.ecs_task.id]
    protocol        = "tcp"
  }
}

# S3
resource "aws_s3_bucket" "backups_dropbox" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  lifecycle_rule {
    id      = "${var.s3_bucket_name}-glacier"
    enabled = true

    transition {
      days          = var.transition_to_glacier_period
      storage_class = "GLACIER"
    }

    transition {
      days          = var.transition_to_deep_archive_period
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.expiration_period
    }

    abort_incomplete_multipart_upload_days = 30
  }
}

resource "aws_s3_bucket_public_access_block" "backups_dropbox_block" {
  bucket = aws_s3_bucket.backups_dropbox.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}