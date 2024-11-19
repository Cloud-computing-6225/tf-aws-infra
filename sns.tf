resource "aws_sns_topic" "user_verification_topic" {
  name = "${var.project_name}-user-verification-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.user_verification_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.user_verification_function.arn
}

resource "aws_iam_policy" "sns_access_policy" {
  name        = "${var.project_name}-SNSAccessPolicy"
  description = "Policy to allow Publish, Subscribe, and GetTopicAttributes access to SNS topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe",
          "sns:Unsubscribe",
          "sns:GetTopicAttributes"
        ],
        Resource = aws_sns_topic.user_verification_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_sns_access_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = aws_iam_policy.sns_access_policy.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_verification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification_topic.arn
}
