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

  if File.exist?("/etc/tfsoa.yaml")
    config = YAML.load_file("/etc/tfsoa.yaml")
    @aws_access_key_id = config["aws_creds"]["aws_access_key_id"]
    @aws_secret_access_key = config["aws_creds"]["aws_secret_access_key"]
  end

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

  def valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError
      return false
    end
  end

  set(:method) do |method|
    method = method.to_s.upcase
    condition { request.request_method == method }
  end

  before :method => :post do
    @req_data = JSON.parse(request.body.read.to_s)
  end

  get '/outputs/*' do
    # Example
    # http://127.0.0.1:9292/tfsoa/outputs/autozane_kafka_awslogs_cloudwatch%2Fpromotion%2FTerraform
    @state_entry = Tfstate.find_by s3_bucket_key: params[:splat]
    @state_entry_last_details = @state_entry.state_details.last
    @state_entry_json = JSON.parse(@state_entry_last_details.state_json)
    erb :outputs
  end

  post '/add_tf_state/:team/:product/:service/:environment/' do
    # HTTP post TF state json to then endpoint
    @params = params
    valid_json(@req_data)
    state = load_tf_state_ruby_hash(@req_data)
    raw_state = @req_data
    create_tf_entry(state, raw_state, @params[:team], @params[:product],
      @params[:service], @params[:environment])
  end

end
