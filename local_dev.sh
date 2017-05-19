#!/bin/bash

if [ -f /usr/bin/terraform ]
  then
    echo "Terraform installed"
  else
    wget https://releases.hashicorp.com/terraform/0.9.5/terraform_0.9.5_linux_amd64.zip
    unzip terraform_0.9.5_linux_amd64.zip -d /usr/bin/
fi

apt-get update
apt-get install -y graphviz \
  ruby \
  ruby-dev \
  libsqlite3-dev \
  build-essential \
  libmysqlclient-dev \
  nodejs

gem install bundler puma
cd /vagrant
bundle install
bundle exec rake db:setup
cat << EOF > /etc/systemd/system/tfsoa.service
[Unit]
Description=TFSOA server
After=network.target

[Service]
ExecStart=/usr/local/bin/puma
WorkingDirectory=/vagrant
Restart=always
Type=simple

[Install]
WantedBy=multi-user.target
Alias=tfsoa.service
EOF

/bin/systemctl daemon-reload
/bin/systemctl restart tfsoa

sleep 6
echo "Submit test Terraform states..."
curl 127.0.0.1:9292/tfsoa/add_tf_state/example_team_1/product1/example1/dev/ \
  --silent \
  -H "Content-Type: application/json" \
  -X POST \
  -d @test/fixtures/state1

curl 127.0.0.1:9292/tfsoa/add_tf_state/example_team_2/product2/example1/dev/ \
  --silent \
  -H "Content-Type: application/json" \
  -X POST \
  -d @test/fixtures/state1

pushd test/fixtures/tf_elb
terraform graph -draw-cycles \
  | curl -d @- \
  http://127.0.0.1:9292/tfsoa/add_tf_graph/example_team_1/product1/example1/dev/ \
  --silent
popd

pushd test/fixtures/tf_asg
terraform graph -draw-cycles \
  | curl -d @- \
  http://127.0.0.1:9292/tfsoa/add_tf_graph/example_team_2/product2/example1/dev/ \
  --silent

echo "Navigate to http://127.0.0.1:9292"
