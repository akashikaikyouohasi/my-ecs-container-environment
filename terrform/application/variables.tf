
#####################
# プロジェクト情報
#####################
variable "name" {
  default = "flask-test"
}

#####################
# NWリソース
#####################

#####################
# Systems Manager Parameter Store
####################
locals {
  secret_parameter = {
    db_master_user = {
      name  = "/${var.name}/database/master/user"
      value = "admin"
    }
    db_master_password = {
      name  = "/${var.name}/database/master/password"
      value = "tmp"
    }
    db_app_user = {
      name  = "/${var.name}/database/flaskapp/user"
      value = "user1"
    }
    db_app_password = {
      name  = "/${var.name}/database/flaskapp/password"
      value = "tmp"
    }
  }
}

#####################
# ECR
#####################
locals {
  ecr = {
    app = {
      name         = "${var.name}-app"
      scan_on_push = false
    }
  }
}

#####################
# ECS
#####################
locals {
  ecs_flask = {
    task_definition = {
      name           = "${var.name}-ecs-def"
      container_name = "flask"
      memory_soft    = 512
      cpu            = 256

      image_tag      = "v1"

      #secrets_manager = module.aurora.secretsmanager_secret_db

      ecs_task_iam_name = "${var.name}-EcsTaskRole"
    }
    cluster = {
      name = "${var.name}-cluster"
    }
    ecs_service = {
      name = "${var.name}-ecs-service2"

      subnets = [
        data.terraform_remote_state.common.outputs.private_subnets["${var.name}-private-app-1a"],
        data.terraform_remote_state.common.outputs.private_subnets["${var.name}-private-app-1c"]
      ]
      security_groups = [
        data.terraform_remote_state.common.outputs.sg["app"]
      ]
    }
  }
}

#####################
# Frontend ALB
#####################
locals {
  frontend_albs = {
    frontend_alb = {
      name            = "${var.name}-alb-frontend"
      ip_address_type = "ipv4"
      subnets = [
        data.terraform_remote_state.common.outputs.public_subnets["${var.name}-public-1a"],
        data.terraform_remote_state.common.outputs.public_subnets["${var.name}-public-1c"]
      ]
      security_groups = [
        data.terraform_remote_state.common.outputs.sg["alb"]
      ]
      lister = {
        port       = "80"
        protocol   = "HTTP"
        default_tg = "frontend_alb"
      }
    }
  }
  target_group_frontend = {
    frontend_alb = {
      lb           = "frontend_alb"
      name         = "${var.name}-tg-frontend"
      health_check = "/"
      port         = "80"
    }
  }
}
