resource "aws_codepipeline" "dofs_pipeline" {
  name     = "dofs-pipeline"
  role_arn = aws_iam_role.codebuild_role.arn

  artifact_store {
    location = "your-artifacts-bucket"  # replace with your S3 bucket name (must exist)
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = "kaamilullah"              # replace with your GitHub username
        Repo       = "Dofs-Project"             # replace with your repo name
        Branch     = "main"
        OAuthToken = var.github_token           # store your GitHub Personal Access Token as a TF variable/secret
      }
    }
  }

  stage {
    name = "Build"

    action {
      name              = "Build"
      category          = "Build"
      owner             = "AWS"
      provider          = "CodeBuild"
      input_artifacts   = ["SourceArtifact"]
      output_artifacts  = ["BuildArtifact"]
      version           = "1"

      configuration = {
        ProjectName = aws_codebuild_project.dofs_codebuild.name
      }
    }
  }
}
