##################
# CodeDeploy
##################
resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = local.code_deply.name
}

resource "aws_codedeploy_deployment_group" "app" {
  app_name = aws_codedeploy_app.app.name
  # デプロイグループ名
  deployment_group_name = local.code_deply.name
  # サービスロール
  service_role_arn = aws_iam_role.codedeploy.arn
  # 環境設定
  ecs_service {
    cluster_name = aws_ecs_cluster.frontend.name
    service_name = aws_ecs_service.frontend.name
  }
  # Load balancer
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.frontend_alb.arn]
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.frontend_alb_green.arn]
      }
      target_group {
        name = aws_lb_target_group.frontend_alb.name
      }
      target_group {
        name = aws_lb_target_group.frontend_alb_green.name
      }
    }
  }
  # デプロイ設定
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 10
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 60
    }
  }

  # ロールバック
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}


#####################
# IAM
#####################
# AWS管理ポリシー取得
data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# IAM Role
data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "codedeploy" {
  name               = local.code_deply.iam_name
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "codedeploy" {
  name       = local.code_deply.iam_name
  roles      = [aws_iam_role.codedeploy.name]
  policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
}