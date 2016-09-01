provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "shared" {
  backend = "s3"

  config {
    bucket = "${var.s3_shared_bucket}"
    key    = "${var.s3_bucket_key}"
    region = "us-east-1"
  }
}

module "client" {
  source = "github.com/callmeradical/terraformations//aws_node"

  aws_region          = "us-east-1"
  vpc_id              = "${data.terraform_remote_state.shared.vpc_id}"
  ssh_from            = "0.0.0.0/0"
  subnet_id           = "${data.terraform_remote_state.shared.vpc_subnet_2}"
  key_name            = "${var.key_name}"
  ami                 = "ami-6869aa05"
  instance_type       = "c4.8xlarge"
  name                = "Aurora Client"
  project             = "Aurora_Benchmark"
  security_group_name = "aurora_client8x"
  iam_role_name       = "aurora_client_role8x"
  user_data           = "${data.template_file.bootstrap.rendered}"
}

data "template_file" "bootstrap" {
  template = "${file("../templates/bootstrap.sh.tpl")}"

  vars {
    settings = "${data.template_file.settings.rendered}"
    gendata  = "${data.template_file.gendata.rendered}"
    runtest  = "${data.template_file.runtest.rendered}"
  }
}

data "template_file" "settings" {
  template = "${file("../templates/settings.cf.tpl")}"

  vars {
    test_system    = "aurora-8xl"
    mysql_host     = "${module.aurora_r3_8x1.endpoint}"
    mysql_user     = "${var.username}"
    mysql_password = "${var.password}"
    mysql_db       = "aurorabench4x1"
  }
}

data "template_file" "gendata" {
  template = "${file("../templates/gendata.sh.tpl")}"

  vars {
    mysql_host     = "${module.aurora_r3_8x1.endpoint}"
    mysql_user     = "${var.username}"
    mysql_password = "${var.password}"
    mysql_db       = "aurorabench4x1"
  }
}

data "template_file" "runtest" {
  template = "${file("../templates/runtest.sh.tpl")}"

  vars {
    test_system    = "aurora-8xl"
    test_path      = "oltp"
    test_name      = "aurora-8xl"
    mysql_host     = "${module.aurora_r3_8x1.endpoint}"
    mysql_user     = "${var.username}"
    mysql_password = "${var.password}"
    mysql_db       = "aurorabench4x1"
  }
}

module "aurora_r3_8x1" {
  source = "../modules/rds_snapshot"

  aws_region           = "us-east-1"
  storage              = ""
  engine_version       = ""
  engine               = "aurora"
  instance_class       = "db.r3.8xlarge"
  dbname               = "aurorabench4x1"
  name                 = "aurorabench8x2"
  username             = "${var.username}"
  password             = "${var.password}"
  db_subnet_group_name = "aurora_bench_8x2"
  subnet_frontend_id   = "${data.terraform_remote_state.shared.vpc_subnet_1}"
  subnet_backend_id    = "${data.terraform_remote_state.shared.vpc_subnet_2}"
  parameter_group_name = "${var.parameter_group_name}"
  snapshot_identifier  = "${var.snapshot_identifier}"
}
