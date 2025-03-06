# 4. 創建 DMS Replication Task，僅同步 INSERT
resource "aws_dms_replication_task" "dms_task" {
  replication_task_id          = "dms-cdc-task"
  migration_type               = "cdc"  # 只啟用 CDC
#   cdc_start_time               = "2025-03-05T00:00:00Z"
  replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
  source_endpoint_arn          = aws_dms_endpoint.pg_source.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.kinesis_target.endpoint_arn
  table_mappings               = <<EOF
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "select_tables",
      "object-locator": {
        "schema-name": "public",
        "table-name": "%"
      },
      "rule-action": "include"
    },
    {
      "rule-type": "selection",
      "rule-id": "2",
      "rule-name": "exclude_updates_deletes",
      "object-locator": {
        "schema-name": "public",
        "table-name": "%"
      },
      "rule-action": "exclude",
      "rule-action-condition": {
        "operation": ["update", "delete"]
      }
    }
  ]
}
EOF
}