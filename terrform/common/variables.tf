#####################
# NWリソース
#####################
variable "name" {
  default = "flask-test"
}

locals {
  cidr_block = "10.0.0.0/16"
}

locals {
  public_subnets = {
    public-1a = {
      name              = "${var.name}-public-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.0.0/24"
      route_table_name  = "public"
    }
    public-1c = {
      name              = "${var.name}-public-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.1.0/24"
      route_table_name  = "public"
    }
  }

  private_subnets = {
    private-app-1a = {
      name              = "${var.name}-private-app-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.10.0/24"
      route_table_name  = "app"
    }
    private-app-1c = {
      name              = "${var.name}-private-app-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.11.0/24"
      route_table_name  = "app"
    }
    private-db-1a = {
      name              = "${var.name}-private-db-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.20.0/24"
      route_table_name  = "db"
    }
    private-db-1c = {
      name              = "${var.name}-private-db-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.21.0/24"
      route_table_name  = "db"
    }
  }
}

locals {
  public_route_table = {
    public = {
      name = "${var.name}-public"
    }
  }
  private_route_table = {
    app = {
      name = "${var.name}-app"
    }
    db = {
      name = "${var.name}-db"
    }
  }
}

locals {
  security_group = ["app", "db", "alb"]
  security_group_rule = {
    alb = {
      sg                       = "alb"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = null
      cidr_blocks              = "0.0.0.0/0"
    }
    app = {
      sg                       = "app"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = "alb"
      cidr_blocks              = null
    }
    db = {
      sg                       = "db"
      port                     = 3306
      protocol                 = "tcp"
      source_security_group_id = "app"
      cidr_blocks              = null
    }
  }
}

locals {
  nat_gateway = {
    public-1a = {
      name = "${var.name}-nat-gateway"
      route_teble_name = "app"
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
      scan_on_push = true
    }
  }
}
