variable "name" {
  default = "dev-elb"
}

variable "subnet_ids" {
  description = "comma separated list of subnet IDs"
}

variable "security_groups" {
  description = "comma separated list of security group IDs"
}

variable "port" {
  description = "Instance port"
  default = 80
}

variable "health_check_port" {
  description = "Listener for the health_check"
  default = 81
}

variable "health_check_url" {
  description = "The URL the ELB should use for health checks"
  default = "HTTP:80/"
}
