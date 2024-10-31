resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "CloudWatchAgentRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "ec2.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.project_name}-S3AccessPolicy"
  description = "Policy to allow PutObject, DeleteObject, and GetObject access to the specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObject"
        ],
        Resource = "${aws_s3_bucket.app_bucket.arn}/*"
      }
    ]
  })
}


# Attach the AWS-managed CloudWatch Agent policy
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# Attach the custom S3 access policy
resource "aws_iam_role_policy_attachment" "attach_s3_access_policy" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

