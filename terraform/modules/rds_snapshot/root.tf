provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.name}"
  database_name           = "${var.dbname}"
  master_username         = "${var.username}"
  master_password         = "${var.password}"
  db_subnet_group_name    = "${var.db_subnet_group_name}"
  backup_retention_period = 5
  snapshot_identifier     = "${var.snapshot_identifier}"
  preferred_backup_window = "07:00-09:00"
}

resource "aws_rds_cluster_instance" "default" {
  count                = 2
  identifier           = "${var.name}-${count.index}"
  cluster_identifier   = "${aws_rds_cluster.default.id}"
  instance_class       = "${var.instance_class}"
  db_subnet_group_name = "${var.db_subnet_group_name}"
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.db_subnet_group_name}"
  subnet_ids = ["${var.subnet_frontend_id}", "${var.subnet_backend_id}"]

  tags {
    Name      = "${var.db_subnet_group_name}"
    Terraform = "true"
  }
}

output "id" {
  value = "${join(",",aws_rds_cluster_instance.default.*.id)}"
}

output "endpoint" {
  value = "${aws_rds_cluster_instance.default.0.endpoint}"
}

variable "aws_region" {}

variable "dbname" {}

variable "storage" {}

variable "engine" {}

variable "engine_version" {}

variable "instance_class" {}

variable "name" {}

variable "username" {}

variable "password" {}

variable "db_subnet_group_name" {}

variable "parameter_group_name" {}

variable "subnet_frontend_id" {}

variable "subnet_backend_id" {}

variable "snapshot_identifier" {}
