variable "prefix" {
  description = "Name prefix for all AWS resources (e.g. dropbox-to-s3)"
  default     = "dropbox-to-s3"
}

variable "ssm_name" {
  description = "Name of AWS Systems Manager secret containing rclone config"
  default     = "DROPBOX_RCLONE_CONFIG"
}

variable "s3_bucket_name" {
  description = "Desired name for S3 backup bucket"
}

variable "email_address" {
  description = "Mail address to send notifications about backup bucket events to"
}

variable "backup_schedule" {
  description = "Cron schedule for the backup job. Default is once per month on 1st day. Can also be rate(x days) for one backup per x days"
  default     = "cron(0 0 1 * ? *)"
}

variable "transition_to_glacier_period" {
  description = "Number of days to keep backups in S3 Standard"
  default     = 1
}

variable "transition_to_deep_archive_period" {
  description = "Number of days to keep backups in S3 Glacier (>=transition_to_glacier_period+90)"
  default     = 91
}

variable "expiration_period" {
  description = "Number of days after which to remove backups (>=transition_to_deep_archive_period+365)"
  default     = 365
}

variable "ecr_image_version" {
  description = "Image version to use"
  default     = "latest"
}