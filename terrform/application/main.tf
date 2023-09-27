#####################
# Common
#####################
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = "tfstate-terraform-20211204"
    key    = "my-ecs/common.tfstate"
    region = "ap-northeast-1"
  }
}


