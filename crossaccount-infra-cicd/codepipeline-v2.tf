resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = var.pipeline_role_arn

  artifact_store {
    location = var.artifact_store_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      version         = "1"
      output_artifacts = ["source_output"]

      configuration {
        RepositoryName = var.repository_name
        BranchName     = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name   = "Approval"
      category = "Approval"
      owner = "AWS"
      provider = "Manual"
      version = "1"
      input_artifacts = ["build_output"]
      output_artifacts = []

      configuration {
        NotificationArn = var.approval_notification_arn
        CustomData = var.approval_custom_data
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "Terraform"
      version         = "1"
      input_artifacts  = ["build_output"]
      configuration    = var.terraform_deploy_config

      configuration_override {
        aws_provider = {
          version = "3.0"
        }
      }

      run_order       = 1
    }
  }
}
