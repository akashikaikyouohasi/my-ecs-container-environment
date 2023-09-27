#####################
# Systems Manager Parameter Store
#####################
resource "aws_ssm_parameter" "secret_parameter" {
  for_each = local.secret_parameter

  name  = each.value.name
  type  = "SecureString"
  value = each.value.value

  # valueの変更を無視します。
  lifecycle {
    ignore_changes = [
      value
    ]
  }
}