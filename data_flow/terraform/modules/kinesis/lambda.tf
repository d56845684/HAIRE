data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# 建立 Lambda function
resource "aws_lambda_function" "firehose_transform_lambda" {
  function_name    = "firehose_transform_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 60
}

# Lambda IAM Policy (Basic execution)
resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 打包 Lambda 函數
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "modules/kinesis/lambda_function.py"
  output_path = "lambda_function.zip"
}

# Lambda Permission (允許 Firehose 呼叫 Lambda)
resource "aws_lambda_permission" "allow_firehose" {
  depends_on = [ aws_kinesis_firehose_delivery_stream.firehose_stream ]
  statement_id  = "AllowExecutionFromFirehose"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.firehose_transform_lambda.function_name
  principal     = "firehose.amazonaws.com"
  source_arn    = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
}