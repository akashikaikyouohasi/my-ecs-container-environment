
# アカウントID取得
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions_ecs_deploy" {
  name               = "GitHubActionsECSDEploy"
  assume_role_policy = data.aws_iam_policy_document.github_actions_ecs_deploy_assume_role_policy.json
}


data "aws_iam_policy_document" "github_actions_ecs_deploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:akashikaikyouohasi/my-ecs-container-environment:*"]
    }
  }
}

resource "aws_iam_policy" "ecr_ecs_deploy" {
  name   = "ECS-ECR-deploy"
  policy = data.aws_iam_policy_document.ecr_ecs_deploy.json
}
data "aws_iam_policy_document" "ecr_ecs_deploy" {
  statement {
    sid = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "PushImageOnly"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
    ]
    resources = [
      "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
  statement {
    sid = "RegisterTaskDefinition"
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "UpdateService"
    effect = "Allow"
    actions = [
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:ap-northeast-1:${data.aws_caller_identity.current.account_id}:service/*/*"
    ]
  }
  statement {
    sid = "passrole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy_attachment" "ecs_task" {
  name       = "GitHubActionsECSDEploy"
  roles      = [aws_iam_role.github_actions_ecs_deploy.name]
  policy_arn = aws_iam_policy.ecr_ecs_deploy.arn
}
