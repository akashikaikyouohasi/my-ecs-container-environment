
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
