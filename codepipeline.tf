provider "aws" {
    region = "us-east-1"
  }
  
  # Define the source CodeCommit repository
  module "source_repo" {
    source = "git::https://github.com/example/source-repo.git"
  
    # Other module configuration options go here
  }
  
  # Define the target CodeCommit repository in the target AWS account
  resource "aws_codecommit_repository" "target_repo" {
    name = "target-repo"
    description = "Target repository in the target AWS account"
  }
  
  # Define the CodePipeline that will deploy the infrastructure from the source to the target account
  resource "aws_codepipeline" "cross_account_pipeline" {
    name = "cross-account-pipeline"
    role_arn = "arn:aws:iam::123456789012:role/cross-account-pipeline-role" # Replace with your cross-account role ARN
  
    artifact_store {
      type = "S3"
      location = "cross-account-pipeline-bucket"
    }
  
    stage {
      name = "Source"
      action {
        name = "SourceAction"
        category = "Source"
        owner = "AWS"
        provider = "CodeCommit"
        version = "1"
        output_artifacts = ["SourceOutput"]
        configuration = {
          RepositoryName = "${module.source_repo.name}"
          BranchName = "main"
          PollForSourceChanges = "true"
        }
      }
    }
  
    stage {
      name = "Approval"
      action {
        name = "ManualApprovalAction"
        category = "Approval"
        owner = "AWS"
        provider = "Manual"
        version = "1"
        input_artifacts = ["SourceOutput"]
        configuration = {}
      }
    }
  
    stage {
      name = "Deploy"
      action {
        name = "DeployAction"
        category = "Deploy"
        owner = "AWS"
        provider = "Terraform"
        version = "1"
        input_artifacts = ["SourceOutput"]
        configuration = {
          # Replace with your target account deploy role ARN
          assume_role {
            role_arn = "arn:aws:iam::123456789012:role/cross-account-deploy-role"
          }
          backend {
            type = "s3"
            bucket = "my-terraform-state-bucket"
            key = "cross-account-pipeline/terraform.tfstate"
            region = "us-east-1"
          }
          workspace = "cross-account-pipeline"
          # Replace with your Terraform code directory path
          source {
            s3_bucket = "my-terraform-code-bucket"
            s3_key = "cross-account-pipeline/terraform-code.zip"
            version = "0.0.1"
          }
          variables = {
            # Replace with your Terraform variables
            stack_name = "my-stack"
            environment = "production"
          }
        }
      }
    }
  }
  
  # Grant permissions for the source AWS account to access the target CodeCommit repository
  resource "aws_codecommit_repository_policy" "target_repo_policy" {
    repository = "${aws_codecommit_repository.target_repo.name}"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "AllowPushPull"
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::123456789012:root" # Replace with your source account ID
          }
          Action = [
            "codecommit:GitPull",
            "codecommit:GitPush",
          ]
          Resource = "${aws_codecommit_repository.target_repo.arn}"
        }
      ]
    })
  }
  