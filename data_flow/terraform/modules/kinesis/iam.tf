resource "aws_iam_role" "firehose_role" {
  name = "FirehoseS3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      "Sid": "1",
      Effect = "Allow"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    },
  #   {
  #    "Sid": "2",
  #    "Effect": "Allow",
  #    "Principal": {
  #       "Service": "dms.amazonaws.com"
  #    },
  #  "Action": "sts:AssumeRole"
  #  }
   ]
  })
}

resource "aws_iam_policy" "firehose_kinesis_s3_policy" {
  name        = "FirehoseKinesisS3Policy"
  description = "Allow Firehose to read from Kinesis and write to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream", "kinesis:ListStreams"]
        Resource = aws_kinesis_stream.cdc_stream.arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.firehose_bucket.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:CreateLogGroup"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_s3_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_kinesis_s3_policy.arn
}