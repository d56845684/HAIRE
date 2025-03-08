# 4. 創建 DMS Replication Task，僅同步 INSERT
resource "aws_dms_replication_task" "dms_task" {
  replication_task_id          = "dms-cdc-task"
  migration_type               = "cdc"  # 只啟用 CDC
  replication_instance_arn     = aws_dms_replication_instance.dms_instance.replication_instance_arn
  source_endpoint_arn          = aws_dms_endpoint.pg_source.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.kinesis_target.endpoint_arn
  # cdc_start_position = "0/4E39470"  # 替換 LSN(confirmed_flush_lsn)
  table_mappings               = <<EOF
{
  "TargetMetadata": {
    "FailOnNoTablesCaptured": false
  },
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
    }
  ]
}
EOF
}


# ,
#     {
#       "rule-type": "transformation",
#       "rule-id": "2",
#       "rule-name": "filter_only_insert",
#       "rule-action": "include",
#       "rule-target": "column",
#       "object-locator": {
#         "schema-name": "public",
#         "table-name": "%"
#       },
#       "rule-condition": "OPERATION = 'INSERT'"
#     }