variable "state_bucket" {
  description = "Name of the S3 bucket used to store the Terraform state file"
  type        = string
}

variable "external_id" {
  description = "External ID used for cross-account access"
  type        = string
}

variable "deploy_role_arn" {
  description = "ARN of the target account IAM role used for deploying infrastructure"
  type        = string
}
