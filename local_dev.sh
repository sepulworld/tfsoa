#!/bin/bash

function install_system_packages {
  apt-get update
  apt-get install -y graphviz \
    ruby \
    ruby-dev \
    libsqlite3-dev \
    build-essential \
    libmysqlclient-dev \
    nodejs
}

function install_terraform {
  if [ -f /usr/bin/terraform ]
    then
      echo "Terraform already installed"
      echo "$(/usr/bin/terraform -version)"
    else
      wget --quiet https://releases.hashicorp.com/terraform/0.9.5/terraform_0.9.5_linux_amd64.zip
      unzip terraform_0.9.5_linux_amd64.zip -d /usr/bin/
  fi
}

function install_gems {
  gem install bundler puma
  pushd /vagrant || exit
  bundle install
  if [ -f /vagrant/db/development.sqlite3 ]
    then
      echo ""
      echo "/vagrant/db/development.sqlite3 already exists. Remove and re-run 'vagrant provision' if you want to re-create"
      echo ""
  else
    bundle exec rake db:setup
  fi
  popd
}

function setup_systemd {
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
}

function setup_test_states_and_graphs {
  echo "Submit test Terraform states..."
  curl 127.0.0.1:9292/tfsoa/add_tf_state/example_team_1/product1/example1/dev/ \
    --silent \
    -H "Content-Type: application/json" \
    -X POST \
    -d @/vagrant/test/fixtures/state1

  curl 127.0.0.1:9292/tfsoa/add_tf_state/example_team_2/product2/example1/dev/ \
    --silent \
    -H "Content-Type: application/json" \
    -X POST \
    -d @/vagrant/test/fixtures/state1

  pushd /vagrant/test/fixtures/tf_elb
  /usr/bin/terraform graph -draw-cycles \
    | curl -d @- \
    http://127.0.0.1:9292/tfsoa/add_tf_graph/example_team_1/product1/example1/dev/ \
    --silent
  popd

  pushd /vagrant/test/fixtures/tf_asg
  /usr/bin/terraform graph -draw-cycles \
    | curl -d @- \
    http://127.0.0.1:9292/tfsoa/add_tf_graph/example_team_2/product2/example1/dev/ \
    --silent
  echo "Navigate to http://127.0.0.1:9292"
}

function main {
  install_system_packages
  install_terraform
  install_gems
  setup_systemd
  setup_test_states_and_graphs
}

# entry point
main
