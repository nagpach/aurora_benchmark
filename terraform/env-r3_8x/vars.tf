variable "s3_shared_bucket" {}

variable "s3_bucket_key" {}

variable "snapshot_identifier" {}

variable "key_name" {
  default = "aws1"
}

variable "username" {
  default = "foo"
}

variable "password" {
  default = "foobarfoo"
}

variable "parameter_group_name" {
  default = "default.aurora5.6"
}
