variable "db_identifier" {
  description = "The identifier for the RDS PostgreSQL instance"
  type        = string
}

variable "db_version" {
  description = "The version of the PostgreSQL engine"
  type        = string
}

variable "instance_class" {
  description = "The instance type for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
}

variable "db_name" {
  description = "The database name for the RDS instance"
  type        = string
}

variable "db_username" {
  description = "The master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "dms_username" {
  description = "The dms username for the RDS instance"
  type        = string
}

variable "dms_password" {
  description = "The dms password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "firehose_name" {
  description = "The name of the Kinesis Firehose delivery stream"
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where Firehose will deliver data"
  type        = string
}
variable "tags" {
    description = "作為成本估計"
    type = map(string)
    default = {
      "name" = "HAIRE"
    }
  
}