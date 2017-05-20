# tf_asg
Terraform AWS Autoscaling Group Module

### Usage

```hcl
module "asg" {
    source              = "github.com/sepulworld/tf_asg.git?ref=v0.0.1"
    name                = "myasg"
    vpc_zone_subnets    = "subnet-abcdef,subnet-abcdeg"
    security_groups     = "sg-abc123f"
    instance_type       = "t2.medium"
    ami                 = "ami-abc23322"
    key_name            = "mypem"
    user_data           = "userdata"
    asg_min_instances   = "1"
    asg_max_instances   = "3"
    health_check_type   = "ELB"
    load_balancer_names = "myelb"
    availability_zones  = "us-west-2a"
    environment         = "dev"
    team                = "platform"
}
```

See variables.tf for full variable list.

Change the git ref?= to use different git tagged versions of this module. See [CHANGELOG.md](https://github.com/sepulworld/tf_elb/blob/master/CHANGELOG.md) for changes.
