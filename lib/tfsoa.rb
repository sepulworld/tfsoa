require 'sinatra'
require "sinatra/activerecord"
require 'yaml'
require 'json'
require 'aws-sdk'

# Add state to database function PUT endpoint
# Once in database a /jobs/refresh_state.rb will handle updating state based
# upon the source in s3

# docs
# Base URI is /tfsoa

class Tfstate < ActiveRecord::Base
  has_many :state_details
end

class StateDetail < ActiveRecord::Base
  belongs_to :tfstate
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

  def find_s3_bucket_key_entry(s3_bucket_key)
    Tfstate.find_by s3_bucket_key: s3_bucket_key
  end

  def load_tf_state_raw_json(s3_bucket_name, s3_bucket_key, role_arn)
    role_credentials = assume_role(role_arn)
    s3 = Aws::S3::Client.new(credentials: role_credentials)
    resp = s3.get_object(bucket: s3_bucket_name, key: s3_bucket_key)
    raw_state = resp.body.read
    return raw_state
  end

  def load_tf_state_ruby_hash(raw_state)
    tf_state = JSON.parse(raw_state)
    return tf_state
  end

  def create_state_detail_entry(db_transaction,
                                raw_state, state, s3_bucket_name, s3_bucket_key)
    db_transaction.state_details.create(
      state_json: raw_state,
      terraform_version: extract_tf_version(state),
      json_version: extract_json_version(state),
      serial: extract_serial(state),
      )
      puts "HERE IS VERSION #{extract_tf_version(state)} OR #{state['terraform_version']}"
  end

  def create_tf_entry(state, raw_state, s3_bucket_name, s3_bucket_key, role_arn)
    db_transaction = find_s3_bucket_key_entry(s3_bucket_key)
    if db_transaction.nil?
      db_transaction = Tfstate.create(
        s3_bucket_uri: "s3://#{s3_bucket_name}/#{s3_bucket_key}",
        s3_bucket_key: s3_bucket_key,
        role_arn: role_arn)
    end
    create_state_detail_entry(db_transaction,
                              raw_state, state, s3_bucket_name, s3_bucket_key)
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
    raw_state = load_tf_state_raw_json(s3_bucket_name, s3_bucket_key, role_arn)
    state = load_tf_state_ruby_hash(raw_state)
    create_tf_entry(state, raw_state, s3_bucket_name, s3_bucket_key, role_arn)
  end

end
