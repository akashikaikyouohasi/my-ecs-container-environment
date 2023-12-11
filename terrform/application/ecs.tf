#####################
# CloudWatch Logs group
#####################
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/${var.name}/container-logs"
  retention_in_days = 30
}
#####################
# ECS Cluster
#####################
resource "aws_ecs_cluster" "frontend" {
  name = local.ecs_flask.cluster.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
#####################
# ECS Service
#####################
resource "aws_ecs_service" "frontend" {
    # サービス名
    name                               = local.ecs_flask.ecs_service.name
    # クラスター
    cluster                            = aws_ecs_cluster.frontend.id
    # タスクの数
    desired_count                      = 1
    # 起動タイプ
    launch_type = "FARGATE"
    # プラットフォームのバージョン
    platform_version = "1.4.0"
    # タスク定義
    task_definition = "flask-test-app:15"
    

    #iam_role                           = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"

    # ECSで管理されたタグを有効にする
    enable_ecs_managed_tags            = true
    # 新しいデプロイの強制
    force_new_deployment               = null

    enable_execute_command             = false
    health_check_grace_period_seconds  = 0
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    propagate_tags                     = "NONE"
    scheduling_strategy                = "REPLICA"
    tags                               = {}
    tags_all                           = {}
    triggers                           = {}
    wait_for_steady_state              = null

    # deployment_circuit_breaker {
    #     enable   = true
    #     rollback = true
    # }
    deployment_controller {
        #type = "ECS"
        type = "CODE_DEPLOY"
    }
    load_balancer {
        container_name   = "flask"
        container_port   = 80
        target_group_arn = aws_lb_target_group.frontend_alb.arn
    }

    # ネットワーク構成
    network_configuration {
        subnets         = local.ecs_flask.ecs_service.subnets
        security_groups = local.ecs_flask.ecs_service.security_groups
        # パブリックIPの自動割り当て
        assign_public_ip = false
    }

    lifecycle {
        ignore_changes = [desired_count, task_definition, load_balancer]
    }
}