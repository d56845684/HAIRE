resource "aws_db_instance" "postgres" {
  identifier             = var.db_identifier
  engine                = "postgres"
  engine_version        = var.db_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  db_name               = var.db_name
  username              = var.db_username
  password              = var.db_password
  publicly_accessible   = true
  skip_final_snapshot   = true
  parameter_group_name  = aws_db_parameter_group.postgres_cdc.name
  tags = var.tags
  
}

resource "aws_db_parameter_group" "postgres_cdc" {
  name   = "${var.db_identifier}-pg-cdc-params"
  family = "postgres15"

  parameter {
    name  = "max_replication_slots"
    value = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "max_wal_senders"
    value = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pglogical"
    apply_method = "pending-reboot"
  }

  parameter {
    # https://docs.aws.amazon.com/zh_tw/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.FeatureSupport.LogicalReplication.html
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "rds.force_ssl"
    value = "0"  # 允許非加密連線
  }
  tags = var.tags
}