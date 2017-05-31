# Terraform State of Awareness (TFSOA)

A dashboard that helps centralize and monitor disparate [Terraform states](https://www.terraform.io/docs/state/).

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy) 

### Heroku example push quick start

Use Heroku Deploy button above and then run these API calls to put test data on your TFSOA deployment
replacing app_name with the name you give your Heroku endpoint

```bash
curl https://APP_NAME.herokuapp.com/tfsoa/add_tf_state/dpt/product2/service1/dev/ \
  -H "Content-Type: application/json" \
  -X \
  POST -d @test/fixtures/state1
cd test/fixtures/tf_asg/ 
terraform graph \
  | curl -d @- https://APP_NAME.herokuapp.com/tfsoa/add_tf_graph/dpt/product2/service1/dev/
```

<img alt="TFSOA Screenshot" src="https://cloud.githubusercontent.com/assets/26415029/23921750/033ff2b2-08bd-11e7-9d78-632edc2c243b.png">

![Versioned states with environment and version markers](https://cloud.githubusercontent.com/assets/538171/24389114/03a1eaf4-1334-11e7-9a44-367f5d6233c2.jpg)
![Per team managed states](https://cloud.githubusercontent.com/assets/538171/24389121/164dcdbc-1334-11e7-9052-184287bc5ed0.jpg)
![Team layout of TF states](https://cloud.githubusercontent.com/assets/538171/24389129/1ba96988-1334-11e7-8abf-b3c47f43ff27.jpg)

TFSOA accepts pushes of Terraform states and digraph output.

* Versioned backups of state
* Generate graph visual from digraph
* Dashboard to track useful state information

The Terraform version, JSON serial, JSON version and entire state are serialized saved. TFSOA uses
this information across a multitude of states to present a single dashboard interface
to view statistics on all Terraform states.


### Setup database

```
bundle exec rake db:environment:set
bundle exec rake db:setup
bundle exec rake db:migrate
```

### Recommended setup notes

Place behind and SSL endpoint like an Nginx, ELB or Haproxy to handle SSL. Terraform states typically contain sensative information.

### System requirements

* graphviz (used for graph .png creation)
* libsqlite3-dev (Ubuntu)
* nodejs (Ubuntu)
* libmysqlclient-dev (Ubuntu)
* ruby (Ubuntu)
* ruby-dev (Ubuntu)
* build-essential (Ubuntu)

### Start TFSOA

```bash
rackup
```

This will start a rack server on port 9292

### Add your first Terraform state to tfsoa

#### Unique identifiers for state

* team (team name that owns this tf state)
* product (my companies new product this supports)
* service (service name, or project name)
* environment (dev, stage, prod)


#### Example state push

```bash
curl 127.0.0.1:9292/tfsoa/add_tf_state/team/product/service/environment/ \
  -H "Content-Type: application/json" \
  -X \
  POST -d @.terraform/terraform.tfstate
```

#### Example graph push (must push graph to an existing saved state in tfsoa)

```bash
terraform graph \
| curl -d @- http://localhost:9292/tfsoa/add_tf_graph/comms/trulia/someservice/prod/
```

### Development Notes

Current entity-relationship diagram

<img alt="erd diagram" src="https://cloud.githubusercontent.com/assets/26415029/24062446/d3de1626-0b18-11e7-9b96-2bde9bc79124.png">

#### Vagrant support

```bash
vagrant up
```
Then navigate your browser to http://127.0.0.1:9292

Safe to run ```vagrant provision``` to restart tfsoa process if you make local code changes.

### Thank you

Thanks to [Smashing gem](https://github.com/Smashing/smashing) for providing a solid framework for tfsoa to utilize
