# Output the ID of the Launch Config
output "lc_id" {
    value = "${aws_launch_configuration.lc.id}"
}

# Output the ID of the Autoscaling Group
output "asg_id" {
    value = "${aws_autoscaling_group.asg.id}"
}

# Output the Name of the Autoscaling Group
output "asg_name" {
    value = "${aws_autoscaling_group.asg.name}"
}
