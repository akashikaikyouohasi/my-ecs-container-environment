
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

#####################
# Aurora
#####################
locals {
  aurora = {
    db_subnet_group_name = "${var.name}-rds-subnet-group"
    subnet_ids = [
      data.terraform_remote_state.common.outputs.private_subnets["${var.name}-private-db-1a"],
      data.terraform_remote_state.common.outputs.private_subnets["${var.name}-private-db-1c"]
    ]

    engine             = "aurora-mysql"
    engine_version     = "8.0.mysql_aurora.3.04.1"
    cluster_identifier = "${var.name}-db"
    master_username    = "admin"

    instance_class = "db.t3.medium"
    instances = {
      db1 = {
        identifier = "${var.name}-db-instance-1"
      }
      db2 = {
        identifier = "${var.name}-db-instance-2"
      }
    }

    vpc_security_group_ids = [
      data.terraform_remote_state.common.outputs.sg["db"]
    ]
    database_name = "user"

    backup_retention_period = 1
    monitoring_iam_role     = "${var.name}-rds-monitoring-role"

  }
}
