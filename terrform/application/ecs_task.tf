#####################
# ECS Task
#####################
resource "aws_ecs_task_definition" "flask" {
  container_definitions    = jsonencode([
    {
      cpu = 256
      environment = [
        {
          name = "MYSQL_HOST"
          value = aws_rds_cluster.db.endpoint
        },
        {
          name = "MYSQL_DATABASE"
          value = "user"
        }
      ]
      environmentFiles = []
      essential = true
      image = "206863353204.dkr.ecr.ap-northeast-1.amazonaws.com/flask-test-app:60aadad5244b7ac8deef90bc06ee2f4a0b4fcb24"
      logConfiguration= {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group = "/flask-test/container-logs"
          awslogs-region = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
      memory = 512
      memoryReservation = 512
      mountPoints = []
      name = "flask"
      portMappings = [
        {
          appProtocol = "http"
          containerPort = 80
          hostPort = 80
          name = "flask-80-tcp"
          protocol = "tcp"
        }
      ]
      readonlyRootFilesystem = true
      secrets = [
        {
          name = "MYSQL_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.aurora.id}:password::" 
        },
        {
          name = "MYSQL_USER"
          valueFrom = "${data.aws_secretsmanager_secret.aurora.id}:username::" 
        }
      ]
      ulimits = []
      volumesFrom = []
    }
  ])
  cpu                      = "256"
  execution_role_arn       = "arn:aws:iam::206863353204:role/flask-test-EcsTaskRole"
  family                   = "flask-test-app"
  ipc_mode                 = null
  memory                   = "512"
  network_mode             = "awsvpc"
  pid_mode                 = null
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = null
  tags                     = {}
  tags_all                 = {}
  task_role_arn            = "arn:aws:iam::206863353204:role/flask-test-EcsTaskRole"
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}
