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
     puts state
  end

  def load_tf_state(s3_bucket_name, s3_bucket_key, role_arn)
    role_credentials = assume_role(role_arn)
    s3 = Aws::S3::Client.new(credentials: role_credentials)
    resp = s3.get_object(bucket: s3_bucket_name, key: s3_bucket_key)
    tf_state = JSON.parse(resp.body.read)
    return tf_state
  end

  before do
      @req_data = JSON.parse(request.body.read.to_s)
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
    extract_tf_version(load_tf_state(s3_bucket_name, s3_bucket_key, role_arn))
  end

end
