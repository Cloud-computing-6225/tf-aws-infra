resource "aws_lambda_function" "user_verification_function" {
  function_name = "${var.project_name}-user-verification"
  runtime       = "nodejs18.x"
  handler       = var.handler_path
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = var.lambda_package_path

  environment {
    variables = {
      SENDGRID_API_KEY    = var.sendgrid_api_key
      BASE_URL            = "http://${var.domain_name}"
      SENDGRID_FROM_EMAIL = var.SENDGRID_FROM_EMAIL
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
