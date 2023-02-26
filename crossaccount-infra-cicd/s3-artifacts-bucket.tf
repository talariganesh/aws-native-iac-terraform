resource "aws_s3_bucket" "dev" {
  bucket = "dev-artifact-store"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true

    rule {
      id      = "expire-old-artifacts"
      status  = "Enabled"
      prefix  = ""
      enabled = true

      expiration {
        days = 30
      }
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.dev.id
}
