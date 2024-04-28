module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "kube-hetzner-postgres-backups"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

resource "aws_iam_user" "kube-hetzner-s3-user" {
  name = "kube-hetzner-s3-user"

}

resource "aws_iam_policy" "s3_access" {
  name        = "S3AccessPolicy"
  description = "Policy for allowing an IAM user to access a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "${module.s3_bucket.s3_bucket_arn}/*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.kube-hetzner-s3-user.name
  policy_arn = aws_iam_policy.s3_access.arn
}
