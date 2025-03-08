module "rds" {
  source = "./modules/databases"

  db_identifier      = var.db_identifier
  db_version        = var.db_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "kinesis" {
  source = "./modules/kinesis"
  firehose_name = "pg-cdc-firehose"
  stream_name = "cdc-data-stream"
  tags = var.tags
}

module "dms" {
  depends_on = [module.kinesis, module.rds]
  source = "./modules/dms"
  replication_instance_id = "dms-pg-cdc"
  replication_instance_class = "dms.t3.micro"
  allocated_storage = 100
  dms_username = var.dms_username
  dms_password = var.dms_password
  db_name = var.db_name
  postgres_endpoint = module.rds.postgres_endpoint
  kinesis_arn = module.kinesis.kinesis_arn
  kinesis_role_arn = module.kinesis.firehose_role_arn
  tags = var.tags
}