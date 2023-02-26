# Define the cross-account IAM role
resource "aws_iam_role" "cross_account_role" {
    name = "cross-account-pipeline-role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.source_account_id}:root" # Replace with your source account ID
          }
          Action = "sts:AssumeRole"
          Condition = {
            StringEquals = {
              "sts:ExternalId" = var.external_id
            }
          }
        }
      ]
    })
  }
  
  # Define the IAM role policy to allow deploying infrastructure in the target account
  resource "aws_iam_policy" "cross_account_policy" {
    name = "cross-account-pipeline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "sts:AssumeRole"
          ]
          Resource = var.deploy_role_arn
        },
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:PutObjectAcl"
          ]
          Resource = [
            "arn:aws:s3:::${var.state_bucket}/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "ec2:*",
            "rds:*",
            "elasticache:*",
            "s3:*",
            "sns:*",
            "cloudfront:*",
            "iam:*",
            "route53:*",
            "lambda:*",
            "apigateway:*",
            "acm:*",
            "logs:*",
            "cloudwatch:*",
            "cloudwatchlogs:*",
            "elbv2:*",
            "autoscaling:*",
            "eks:*"
          ]
          Resource = "*"
        },
        {
          Effect = "Allow"
          Action = [
            "sts:GetCallerIdentity"
          ]
          Resource = "*"
        }
      ]
    })
  }
  