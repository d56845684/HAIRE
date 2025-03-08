variable "firehose_name" {
  description = "Kinesis Firehose name"
  type        = string
  default     = "firehose-delivery"
}
variable "stream_name" {
  description = "Kinesis Data Stream name"
  type        = string
  default     = "cdc-stream"
}
variable "tags" {
    description = "作為成本估計"
    type = map(string)
    default = {
      "name" = "HAIRE"
    }
  
}