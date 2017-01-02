# Terraform State of Awareness (TFSOA)

A [smashing](https://github.com/Smashing/smashing) dashboard interface that helps centralize
and monitor disparate [Terraform remote states](https://www.terraform.io/docs/state/).

TFSOA registers remote Terraform states (in s3 only presently) in a local database.
The Terraform version, JSON serial, JSON version and entire state are saved. TFSOA uses
this information across a multitude of states to present a single dashboard interface
to view statistics on all Terraform states.

# Provide AWS Role access to TFSOA

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

# Setup database

```
bundle exec rake db:environment:set
bundle exec rake db:setup
bundle exec rake db:migrate
```

# Start tfsoa

```bash
rackup
```
This will start a rack server on port 9292

# Add your first Terraform state to tfsoa, using your AWS Role you created

```bash
curl 127.0.0.1:9292/tfsoa/add_tf_state \
  -H "Content-Type: application/json" \
  -X \
  POST -d '{"role_arn": "arn:aws:iam::357170183134:role/s3read","s3_bucket_name": "terraform-autozane-remote-state","s3_bucket_key": "golang-app-dev/promotion/Terraform"}'
```
