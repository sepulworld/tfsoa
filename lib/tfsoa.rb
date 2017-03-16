require 'sinatra'
require "sinatra/activerecord"
require 'yaml'
require 'json'

if development?
  require 'awesome_print'
  AwesomePrint.irb!
end

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
  serialize :state_json, Hash
end

class TerraformSOA < Sinatra::Base

  register Sinatra::ActiveRecordExtension
  set :database_file, "../config/database.yml"
  def extract_tf_version(state)
     state['terraform_version']
  end

  def extract_json_version(state)
     state['version']
  end

  def extract_serial(state)
     state['serial']
  end

  def find_unique_tf_state_entry(unique_tf_state)
    Tfstate.find_by unique_tf_state: unique_tf_state
  end

  def load_tf_state_ruby_hash(raw_state)
    tf_state = JSON.parse(raw_state)
    return tf_state
  end

  def create_state_detail_entry(db_transaction, raw_state, state)
    db_transaction.state_details.create(
      state_json: state,
      terraform_version: extract_tf_version(state),
      json_version: extract_json_version(state),
      serial: extract_serial(state),
      )
  end

  def create_tf_entry(state, raw_state, team, product, service, environment)
    unique_tf_state = "#{team}-#{product}-#{service}-#{environment}"
    db_transaction = find_unique_tf_state_entry(unique_tf_state)
    if db_transaction.nil?
      db_transaction = Tfstate.create(unique_tf_state: unique_tf_state)
    end
    create_state_detail_entry(db_transaction, raw_state, state)
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

  get '/outputs/*' do
    # Example
    # http://127.0.0.1:9292/tfsoa/outputs/dataplatform/silverbullet/zookeeper/dev
    @state_entry = Tfstate.find_by unique_tf_state: params[:splat]
    @state_entry_last_details = @state_entry.state_details.last
    @state_entry_json = JSON.parse(@state_entry_last_details.state_json)
    erb :outputs
  end

  post '/add_tf_state/:team/:product/:service/:environment/' do
    # HTTP post TF state json to then endpoint
    @params = params
    create_tf_entry(JSON.parse(request.body.read), request.body.read, @params[:team], @params[:product],
      @params[:service], @params[:environment])
  end

  get '/list' do
    @all_states = Tfstate.all
    erb :list_states
  end

  get '/show/:unique_tf_state' do
    @state = Tfstate.where(unique_tf_state: params[:unique_tf_state]).first
    erb :show_state
  end

  get '/show_state/:id' do
    @state_detail = StateDetail.find(params[:id])
    erb :show_state_detail
  end

  get '/download_state/:id' do
    @state_detail = StateDetail.find(params[:id])
    content_type :json
    @state_detail.state_json.to_json
  end

  post '/add_tf_graph/:team/:product/:service/:environment/' do
    unique_tf_state = "#{params[:team]}-#{params[:product]}-#{params[:service]}-#{params[:environment]}"
    state_detail = Tfstate.where(unique_tf_state: unique_tf_state).first.state_details.last
    state_detail.update_attribute(:digraph, URI.unescape(request.body.read))
  end

  get '/render_graph/:state_detail_id' do
    state_detail = StateDetail.find(params[:state_detail_id])
    digraph = state_detail.digraph
    File.open("/tmp/#{state_detail.id}.dot", 'w') { |file| file.write(digraph) }
    `dot -Tpng /tmp/#{state_detail.id}.dot -o public/#{state_detail.id}.png`
    redirect "#{state_detail.id}.png"
  end
end
