# Terraform State of Awareness (TFSOA)

A [smashing](https://github.com/Smashing/smashing) dashboard interface that helps centralize
and monitor disparate [Terraform remote states](https://www.terraform.io/docs/state/).

<img width="1015" alt="screen shot 2017-01-07 at 11 25 55 pm" src="https://cloud.githubusercontent.com/assets/538171/21748116/eb7b227e-d530-11e6-8746-3c62940bf080.png">

TFSOA registers remote Terraform states (in s3 only presently) in a local database.
The Terraform version, JSON serial, JSON version and entire state are saved. TFSOA uses
this information across a multitude of states to present a single dashboard interface
to view statistics on all Terraform states.

### Setup TFSOA /etc/tfsoa.yaml

```yaml
---
# place configuration at /etc/tfsoa.yaml
aws_creds:
  aws_access_key_id: "key_here"
  aws_secret_access_key: "secret_here"
```

### Provide an AWS Role for TFSOA to use on each AWS account that you intend to monitor Terraform state files on

TFSOA will leverage the role arn when inputing a new state into TFSOA, see [here](https://github.com/sepulworld/tfsoa#add-your-first-terraform-state-to-tfsoa-using-your-aws-role-you-created)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "*"
            ]
        }
    ],
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
   ]
}
```

### Setup database

```
bundle exec rake db:environment:set
bundle exec rake db:setup
bundle exec rake db:migrate
```

### Start TFSOA

```bash
rackup
```
This will start a rack server on port 9292

### Add your first Terraform state to tfsoa, using your AWS Role you created

```bash
curl 127.0.0.1:9292/tfsoa/add_tf_state \
  -H "Content-Type: application/json" \
  -X \
  POST -d '{"role_arn": "arn:aws:iam::357170183134:role/s3read","s3_bucket_name": "terraform-autozane-remote-state","s3_bucket_key": "golang-app-dev/promotion/Terraform"}'
```

### Development Notes

Current entity-relationship diagram

<img width="1158" alt="screen shot 2017-01-02 at 6 37 01 pm" src="https://cloud.githubusercontent.com/assets/538171/21599015/e581df58-d11a-11e6-817f-3ea81895bd98.png">
