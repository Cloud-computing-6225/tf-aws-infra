resource "aws_lambda_function" "user_verification_function" {
  function_name = "${var.project_name}-user-verification"
  runtime       = "nodejs18.x"
  handler       = var.handler_path
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = var.lambda_package_path

  environment {
    variables = {
      # SENDGRID_API_KEY    = var.sendgrid_api_key
      BASE_URL            = "http://${var.domain_name}"
      # SENDGRID_FROM_EMAIL = var.SENDGRID_FROM_EMAIL
    }
  }
}


resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_policy" "lambda_secrets_access_policy" {
  name        = "${var.project_name}-lambda-secrets-access-policy"
  description = "Allow Lambda to access email service credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
         Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_secretsmanager_secret.email_service_secret.arn}",
          "${aws_secretsmanager_secret.email_from_email_secret.arn}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
        ],
        Resource = [
          "${aws_kms_key.secrets_kms_key.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_access_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_secrets_access_policy.arn
}
