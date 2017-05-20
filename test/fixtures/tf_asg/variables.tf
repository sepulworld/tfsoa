variable "name" {
}

variable "ami" {
  description = "The AMI to use with the launch configuration"
  default = "updateme"
}

variable "associate_public_ip" {
  default = false
}

variable "instance_type" {
  default = "t2.medium"
}

variable "instance_profile" {
  description = "The IAM role the launched instance will use"
}

variable "key_name" {
  description = "The SSH public key name (in EC2 key-pairs) to be injected into instances"
}

variable "security_group" {
  description = "ID of SG the launched instance will use"
}

variable "user_data" {
  description = "The path to a file with user_data for the instances"
}

variable "asg_instances" {
  description = "The number of instances we want in the ASG"
  default = 2
}

variable "asg_min_instances" {
  description = "The minimum number of instances the ASG should maintain"
  default = 2
}

variable "asg_max_instances" {
  description = "The maximum number of instances the ASG should maintain"
  default = 4
}

variable "asg_wait_for_capacity" {
  description = "The maximum number of instances the ASG should maintain"
  default = 4
}

variable "asg_wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. Default 10m"
  default = "10m" 
}

variable "health_check_grace_period" {
  description = "Number of seconds for a health check to time out"
  default = 300
}
/*
 * Types available are:
 *   - ELB
 *   - EC2
 *
 *   @see-also: http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html#options
 */
variable "health_check_type" {
  description = "The health check used by the ASG to determine health"
  default = "ELB"
}

variable "load_balancer_names" {
  description = "A comma separated list string of ELB names the ASG should associate instances with"
}

variable "availability_zones" {
  description = "A comma separated list string of AZs the ASG will be associated with"
}

variable "vpc_zone_subnets" {
  description = "A comma separated list string of VPC subnets to associate with ASG, should correspond with var.availability_zones zones"
}

variable "environment" {
  description = "AWS Environment tag, example 'dev', 'stage' or 'prod'. Defaults to 'unknown'"
  default = "unknown"
}

variable "team" {
  description = "AWS tag 'Team' used to associate with a compnay team, example 'web-team' or 'datascience-team'"
  default = "unknown"
}
