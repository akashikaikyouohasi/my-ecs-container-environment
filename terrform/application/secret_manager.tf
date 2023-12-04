#####################
# Secret Manager
#####################
# Auroraで自動作成されるものを取得する
data "aws_secretsmanager_secret" "aurora" {
  arn = aws_rds_cluster.db.master_user_secret[0].secret_arn
}
