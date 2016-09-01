provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "github.com/callmeradical/terraformations//vpc_nat"

  aws_region       = "us-east-1"
  default_vpc_cidr = "10.99.0.0/16"
  public_a_subnet  = "10.99.0.0/24"
  public_b_subnet  = "10.99.1.0/24"
  private_a_subnet = "10.99.2.0/24"
  private_b_subnet = "10.99.3.0/24"
  vpc_name         = "Aurora Benchmark"
  az1              = "us-east-1a"
  az2              = "us-east-1b"
}

module "bastion" {
  source = "github.com/callmeradical/terraformations//aws_bastion"

  aws_region    = "us-east-1"
  vpc_id        = "${module.vpc.vpc}"
  ssh_from      = "0.0.0.0/0"
  subnet_id     = "${module.vpc.public_1}"
  key_name      = "${var.key_name}"
  ami           = "ami-6869aa05"
  instance_type = "t2.micro"
  name          = "Aurora Bastion"
  project       = "Aurora_Benchmark"
}

module "client" {
  source = "github.com/callmeradical/terraformations//aws_node"

  aws_region          = "us-east-1"
  vpc_id              = "${module.vpc.vpc}"
  ssh_from            = "0.0.0.0/0"
  subnet_id           = "${module.vpc.subnet_1}"
  key_name            = "${var.key_name}"
  ami                 = "ami-6869aa05"
  instance_type       = "c4.8xlarge"
  name                = "Aurora Client"
  project             = "Aurora_Benchmark"
  security_group_name = "aurora_client"
  iam_role_name       = "aurora_client_role"
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
    mysql_host     = "${module.aurora_r3_4x1.endpoint}"
    mysql_user     = "${var.username}"
    mysql_password = "${var.password}"
    mysql_db       = "aurorabench4x1"
  }
}

data "template_file" "gendata" {
  template = "${file("../templates/gendata.sh.tpl")}"

  vars {
    mysql_host     = "${module.aurora_r3_4x1.endpoint}"
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
    mysql_host     = "${module.aurora_r3_4x1.endpoint}"
    mysql_user     = "${var.username}"
    mysql_password = "${var.password}"
    mysql_db       = "aurorabench4x1"
  }
}

module "aurora_r3_4x1" {
  source = "../modules/rds"

  aws_region           = "us-east-1"
  storage              = "1000"
  engine               = "aurora"
  engine_version       = ""
  instance_class       = "db.r3.4xlarge"
  name                 = "aurorabench4x1"
  username             = "${var.username}"
  password             = "${var.password}"
  db_subnet_group_name = "aurora_bench_4x1"
  subnet_frontend_id   = "${module.vpc.subnet_1}"
  subnet_backend_id    = "${module.vpc.subnet_2}"
  parameter_group_name = "${var.parameter_group_name}"
}
