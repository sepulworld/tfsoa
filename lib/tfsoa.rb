require 'sinatra'
require "sinatra/activerecord"
require 'yaml'
require 'json'
require 'aws-sdk'

# Todo
# Assume role function
# http://docs.aws.amazon.com/sdkforruby/api/Aws/AssumeRoleCredentials.html

# Add state to database function PUT endpoint
# Once in database a /jobs/refresh_state.rb will handle updating state based
# upon the source in s3

# docs
# Base URI is /tfsoa

class Tfstate < ActiveRecord::Base
  has_many :state_details
end

class State_detail < ActiveRecord::Base
end

class TerraformSOA < Sinatra::Base

  register Sinatra::ActiveRecordExtension
  set :database_file, "../config/database.yml"

  config = YAML.load_file("/etc/tfsoa.yaml")
  @aws_access_key_id = config["aws_creds"]["aws_access_key_id"]
  @aws_secret_access_key = config["aws_creds"]["aws_secret_access_key"]

  def assume_role(role_arn)
    role_credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: role_arn,
      role_session_name: "tfsoa-read"
    )
    return role_credentials
  end

  def extract_tf_version(state)
     state['terraform_version']
  end

  def extract_json_version(state)
     state['version']
  end

  def extract_serial(state)
     state['serial']
  end

  def load_tf_state(s3_bucket_name, s3_bucket_key, role_arn)
    role_credentials = assume_role(role_arn)
    s3 = Aws::S3::Client.new(credentials: role_credentials)
    resp = s3.get_object(bucket: s3_bucket_name, key: s3_bucket_key)
    tf_state = JSON.parse(resp.body.read)
    return tf_state
  end

  def create_tf_entry(state, s3_bucket_name, s3_bucket_key, role_arn)
    db_transaction = Tfstate.find_by s3_bucket_key: s3_bucket_key
    if db_transaction.nil?
      db_transaction = Tfstate.create(
        s3_bucket_uri: "s3://#{s3_bucket_name}/#{s3_bucket_key}",
        s3_bucket_key: "#{s3_bucket_key}",
        role_arn: "#{role_arn}")
    end
    State_detail.create(
      tfstate_id: db_transaction.id,
      state_json: "#{@req_data}",
      terraform_version: "#{extract_tf_version(state)}",
      json_version: "#{extract_json_version(state)}")
  end

  set(:method) do |method|
    method = method.to_s.upcase
    condition { request.request_method == method }
  end

  before :method => :post do
    @req_data = JSON.parse(request.body.read.to_s)
  end

  get '/all_states' do
    states = Tfstate.all
    puts states
  end

  post '/add_tf_state' do
    # example JSON input body
    # {
    #   "role_arn": "arn:aws:iam::357170183134:role/s3read",
    #   "s3_bucket_name": "terraform-autozane-remote-state",
    #   "s3_bucket_key": "autozane_kafka_awslogs_cloudwatch/promotion/Terraform"
    # }
    s3_bucket_name = @req_data['s3_bucket_name']
    s3_bucket_key = @req_data['s3_bucket_key']
    role_arn = @req_data['role_arn']
    create_tf_entry(@req_data, s3_bucket_name, s3_bucket_key, role_arn)
  end

end
