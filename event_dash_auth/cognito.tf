# -----------------------------------------------------------------------------
# Cognito User Pool (for event-dash-auth)
# -----------------------------------------------------------------------------
resource "aws_cognito_user_pool" "this" {
  name = "${var.environment}-${local.app_name}-pool"

  username_attributes     = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  tags = merge(var.tags, { Name = "${var.environment}-${local.app_name}-pool" })
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.cognito_domain_prefix != "" ? var.cognito_domain_prefix : replace("${var.environment}-${local.app_name}-${data.aws_caller_identity.current.account_id}", "_", "-")
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.environment}-${local.app_name}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers        = ["COGNITO"]

  callback_urls = [
    "https://${aws_lb.app.dns_name}/oauth2/idpresponse"
  ]
  logout_urls = [
    "https://${aws_lb.app.dns_name}"
  ]

  generate_secret = true

  id_token_validity      = 60
  access_token_validity  = 60
  refresh_token_validity = 30
  token_validity_units {
    id_token      = "minutes"
    access_token  = "minutes"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_group" "viewers" {
  name         = "viewers"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Read-only access"
  precedence   = 10
}

resource "aws_cognito_user_group" "editors" {
  name         = "editors"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Read and write access"
  precedence   = 5
}

resource "aws_cognito_user_group" "admins" {
  name         = "admins"
  user_pool_id = aws_cognito_user_pool.this.id
  description  = "Full access"
  precedence   = 0
}
