resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key for EC2"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = {
    Name = "${var.project_name}-ec2-kms-key"
  }
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = {
    Name = "${var.project_name}-rds-kms-key"
  }
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS key for S3 buckets"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = {
    Name = "${var.project_name}-s3-kms-key"
  }
}

data "aws_caller_identity" "current" {}


resource "aws_kms_key" "secrets_kms_key" {
  description             = "KMS key for Secrets Manager"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  tags = {
    Name = "${var.project_name}-secrets-kms-key"
  }

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowRootUser",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action    = "kms:*",
        Resource  = "*"
      },
      {
        Sid       = "AllowKeyUsage",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.cloudwatch_agent_role.name}"
        },
        Action    = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        Resource  = "*"
      }
    ]
  })
}



