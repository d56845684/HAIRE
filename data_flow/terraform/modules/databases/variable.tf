variable "db_identifier" {}
variable "db_version" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "tags" {
    description = "作為成本估計"
    type = map(string)
    default = {
      "name" = "HAIRE"
    }
  
}