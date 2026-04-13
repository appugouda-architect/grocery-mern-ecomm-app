# Single JSON secret containing all sensitive app configuration.
# Terraform creates the shell; you populate real values via CI/CD or manually:
#
#   aws secretsmanager put-secret-value \
#     --secret-id <secret_arn> \
#     --secret-string '{
#       "MONGO_URI":             "mongodb+srv://user:pass@cluster.mongodb.net/grocery-app",
#       "JWT_SECRET":            "your-strong-random-secret",
#       "SELLER_EMAIL":          "admin@yourdomain.com",
#       "SELLER_PASSWORD":       "your-admin-password",
#       "CLOUDINARY_CLOUD_NAME": "your-cloud-name",
#       "CLOUDINARY_API_KEY":    "your-api-key",
#       "CLOUDINARY_API_SECRET": "your-api-secret"
#     }'

resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.name_prefix}/app-secrets"
  description             = "All application secrets for ${var.name_prefix}"
  recovery_window_in_days = 7

  tags = { Name = "${var.name_prefix}-app-secrets" }
}

resource "aws_secretsmanager_secret_version" "app" {
  count     = var.create_secret_shells ? 1 : 0
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    MONGO_URI               = "REPLACE_ME"
    JWT_SECRET              = "REPLACE_ME"
    SELLER_EMAIL            = "REPLACE_ME"
    SELLER_PASSWORD         = "REPLACE_ME"
    CLOUDINARY_CLOUD_NAME   = "REPLACE_ME"
    CLOUDINARY_API_KEY      = "REPLACE_ME"
    CLOUDINARY_API_SECRET   = "REPLACE_ME"
  })

  # CRITICAL: prevents Terraform from overwriting real values after initial creation
  lifecycle {
    ignore_changes = [secret_string]
  }
}
