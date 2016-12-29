require 'sinatra'
require "sinatra/activerecord"
require 'yaml'
require 'json'

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

  def self.assume_role(role_arn)
    role_credentials = Aws::AssumeRoleCredentials.new(
      client: Aws::STS::Client.new,
      role_arn: role_arn,
      role_session_name: "tfsoa-read"
    )
  end

  def self.add_tf_state_to_db(s3_bucket_key)

  end

  # Need to refactor for JSON message inputk
  post '/add_tf_state/:arn/:s3_bucket_name/:s3_bucket_key' do
    role_credentials = assume_role(params['arn'])
    s3 = Aws::S3::Client.new(credentials: role_credentials)
    resp = s3.get_object(bucket: params['s3_bucket_name'],
                         key: params['s3_bucket_key'])

  end

end
