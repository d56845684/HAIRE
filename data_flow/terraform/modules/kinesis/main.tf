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
  depends_on = [ 
    aws_kinesis_stream.cdc_stream,
    aws_lambda_function.firehose_transform_lambda
  ]
  name        = var.firehose_name
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.cdc_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
  
  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.firehose_bucket.arn
    buffering_size      = 64
    buffering_interval  = 60
    # 日期路徑設定
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/operation_type=!{partitionKeyFromQuery:operation_type}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    dynamic_partitioning_configuration {
      enabled = "true"
    }
    processing_configuration {
      enabled = "true"
      # # Multi-record deaggregation processor example
      # processors {
      #   type = "RecordDeAggregation"
      #   parameters {
      #     parameter_name  = "SubRecordType"
      #     parameter_value = "JSON"
      #   }
      # }

      # New line delimiter processor example
      processors {
        type = "AppendDelimiterToRecord"
      }

      # JQ processor example
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{operation_type:.metadata.operation}"
        }
      }
    }
    # processing_configuration {
    #   enabled = "true"
    #   processors {
    #     type = "Lambda"

    #     parameters {
    #       parameter_name  = "LambdaArn"
    #       parameter_value = "${aws_lambda_function.firehose_transform_lambda.arn}:$LATEST"
    #     }
    #   }
    # }
  }
  tags = var.tags
}