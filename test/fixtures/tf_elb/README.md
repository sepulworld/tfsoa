# tf_elb
Terraform Module to assist with ELB creation on AWS. Non-HTTPS version

### Usage

```hcl
module "elb" {
    source            = "github.com/sepulworld/tf_elb.git?ref=v0.0.1"
    name              = "myelb"
    subnet_ids        = "subnet-abcdef,subnet-abcdeg"
    security_groups   = "sg-abc123f"
    port              = "80"
    health_check_port = "81"
    health_check_url  = "HTTP:80/"
}
```

See variables.tf for full variable list.

Change the git ref?= to use different git tagged versions of this module. See [CHANGELOG.md](https://github.com/sepulworld/tf_elb/blob/master/CHANGELOG.md) for changes.  
