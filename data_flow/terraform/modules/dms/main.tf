resource "time_sleep" "wait_30_seconds" {
  create_duration = "30s"
}
resource "aws_dms_replication_instance" "dms_instance" {
  depends_on = [time_sleep.wait_30_seconds]
  replication_instance_id   = var.replication_instance_id
  replication_instance_class = var.replication_instance_class
  allocated_storage = var.allocated_storage
  publicly_accessible = true
  engine_version = "3.5.3"
  tags = var.tags
}

resource "aws_dms_endpoint" "pg_source" {
  depends_on = [
    aws_iam_role_policy_attachment.dms_kinesis_attach,
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
  endpoint_id   = "pg-source"
  endpoint_type = "source"
  engine_name   = "postgres"
  username      = var.dms_username
  password      = var.dms_password
  database_name = var.db_name
  port          = 5432
  server_name   = var.postgres_endpoint
  extra_connection_attributes = "pluginName=test_decoding;slotName=dms_replication_slot;CaptureDdls=false;HeartbeatEnable=true"
  # extra_connection_attributes = "pluginName=pglogical;slotName="
  tags = var.tags
}

resource "aws_dms_endpoint" "kinesis_target" {
  depends_on = [
    aws_iam_role_policy_attachment.dms_kinesis_attach,
    aws_iam_role_policy_attachment.dms-access-for-endpoint-AmazonDMSRedshiftS3Role,
    aws_iam_role_policy_attachment.dms-cloudwatch-logs-role-AmazonDMSCloudWatchLogsRole,
    aws_iam_role_policy_attachment.dms-vpc-role-AmazonDMSVPCManagementRole
  ]
  endpoint_id   = "kinesis-target"
  endpoint_type = "target"
  engine_name   = "kinesis"
  kinesis_settings {
    stream_arn = var.kinesis_arn
    message_format = "json"
    service_access_role_arn = aws_iam_role.dms_kinesis_role.arn
  }
  tags = var.tags
}