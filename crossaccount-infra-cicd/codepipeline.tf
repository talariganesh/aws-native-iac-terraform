resource "aws_codepipeline" "dev" {
  name = "dev-pipeline"

  role_arn = "arn:aws:iam::123456789012:role/TerraformCrossAccountRole"

  artifact_store {
    location = aws_s3_bucket.dev.bucket
    type     = "S3"
  }

  stages {
    name = "Source"

    action {
      name            = "SourceAction"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      version         = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = "example-repo"
        BranchName     = "main"
      }

      role_arn = "arn:aws:iam::123456789012:role/TerraformCrossAccountRole"
    }
  }

  stages {
    name = "Deploy"

    variables {
      variable "region" {
        type    = "string"
        default = "us-west-2"
      }

      variable "environment" {
        type    = "string"
        default = "dev"
      }
    }

    action {
      name            = "TerraformApply"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      role_arn        = "arn:aws:iam::123456789012:role/TerraformCrossAccountRole"

      configuration = {
        ProjectName = "example-terraform"
        Environment = "${var.environment}"
        Region      = "${var.region}"
      }
    }
  }
}

output "region" {
  value = "${var.region}"
}

output "environment" {
  value = "${var.environment}"
}
