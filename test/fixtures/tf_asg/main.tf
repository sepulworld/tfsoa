resource "aws_launch_configuration" "lc" {
  lifecycle { create_before_destroy = true }

  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  associate_public_ip_address = "${var.associate_public_ip}"
  iam_instance_profile = "${var.instance_profile}"
  key_name = "${var.key_name}"
  security_groups = ["${var.security_group}"]
  user_data = "${file(var.user_data)}"
}

resource "aws_autoscaling_group" "asg" {
  lifecycle { create_before_destroy = true }

  # We generate a name that includes the launch config name to force a recreate
  name = "asg-${var.name}-${aws_launch_configuration.lc.name}"

  availability_zones = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.vpc_zone_subnets)}"]

  # Uses the ID from the launch config created above
  launch_configuration = "${aws_launch_configuration.lc.id}"

  min_size = "${var.asg_min_instances}"
  max_size = "${var.asg_max_instances}"
  desired_capacity = "${var.asg_instances}"

  wait_for_elb_capacity = "${var.asg_min_instances}"
  wait_for_capacity_timeout = "${var.asg_wait_for_capacity_timeout}"

  health_check_grace_period = "${var.health_check_grace_period}"
  health_check_type = "${var.health_check_type}"

  load_balancers = ["${split(",", var.load_balancer_names)}"]

  tag {
    key = "Name"
    value = "asg-${var.name}-${aws_launch_configuration.lc.name}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Team"
    value = "${var.team}"
    propagate_at_launch = true
  }
}
