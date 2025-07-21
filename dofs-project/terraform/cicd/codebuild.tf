resource "aws_codebuild_project" "dofs_codebuild" {
  name          = "dofs-ci"
  description   = "Build + Deploy via Terraform from GitHub using CodeBuild"

  source {
    type      = "GITHUB"
    location  = "https://github.com/kaamilullah/Dofs-Project.git"  # ✅ replace
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
  }

  service_role = aws_iam_role.codebuild_role.arn
}
