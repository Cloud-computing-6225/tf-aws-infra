resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}<>?\\"
}

# Database password secret
resource "aws_secretsmanager_secret" "db_password_secret" {
  name                    = "${var.project_name}-db_password"
  kms_key_id              = aws_kms_key.secrets_kms_key.id
  recovery_window_in_days = 30

  tags = {
    Name = "${var.project_name}-db_password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = random_password.db_password.result
}

# Store email service credentials in Secrets Manager
resource "aws_secretsmanager_secret" "email_service_secret" {
  name                    = "sendgrid_Api_KeySecret"
  kms_key_id              = aws_kms_key.secrets_kms_key.id
  recovery_window_in_days = 30

  tags = {
    Name = "sendgrid_Api_KeySecret"
  }
}

resource "aws_secretsmanager_secret_version" "email_service_version" {
  secret_id     = aws_secretsmanager_secret.email_service_secret.id
  secret_string = var.sendgrid_api_key
}

# Store the 'From Email' address in a separate secret
resource "aws_secretsmanager_secret" "email_from_email_secret" {
  name                    = "sendgrid_From_EmailSecret"
  kms_key_id              = aws_kms_key.secrets_kms_key.id
  recovery_window_in_days = 30

  tags = {
    Name = "sendgrid_From_EmailSecret"
  }
}

resource "aws_secretsmanager_secret_version" "email_from_email_version" {
  secret_id     = aws_secretsmanager_secret.email_from_email_secret.id
  secret_string = var.SENDGRID_FROM_EMAIL
}
