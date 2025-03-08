resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "firehose-cdc-bucket"
  force_destroy = true
  tags = var.tags
}

resource "aws_s3_bucket_versioning" "firehose_versioning" {
  bucket = aws_s3_bucket.firehose_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "firehose_sse" {
  bucket = aws_s3_bucket.firehose_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_kinesis_stream" "cdc_stream" {
  name        = var.stream_name
  shard_count = 1
  tags = var.tags
}


resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  depends_on = [ aws_kinesis_stream.cdc_stream ]
  name        = var.firehose_name
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.cdc_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.firehose_bucket.arn
    buffering_size      = 5
    buffering_interval  = 10
    # 日期路徑設定
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    processing_configuration {
      
    }
  }
  tags = var.tags
}