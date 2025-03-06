variable "replication_instance_id" {}
variable "replication_instance_class" {}
variable "allocated_storage" {}
variable "dms_username" {}
variable "dms_password" {}
variable "db_name" {}
variable "postgres_endpoint" {}
variable "kinesis_arn" {
  description = ""
}
variable "kinesis_role_arn" {}
variable "tags" {
    description = "作為成本估計"
    type = map(string)
    default = {
      "name" = "HAIRE"
    }
  
}