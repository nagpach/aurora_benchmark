output "vpc_id" {
  value = "${module.vpc.vpc}"
}

output "vpc_subnet_1" {
  value = "${module.vpc.subnet_1}"
}

output "vpc_subnet_2" {
  value = "${module.vpc.subnet_2}"
}
