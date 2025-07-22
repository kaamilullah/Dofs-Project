resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-dofs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_attach_admin" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # For dev; restrict in prod!
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-dofs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # restrict in prod
  role       = aws_iam_role.codepipeline_role.name
}
