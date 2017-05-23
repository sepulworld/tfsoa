require 'sinatra'
require "sinatra/activerecord"
require 'yaml'
require 'json'
require 'digest/sha1'
require 'json-compare'
require 'sinatra/twitter-bootstrap'

if development?
  require 'awesome_print'
  AwesomePrint.irb!
end

class Tfstate < ActiveRecord::Base
  has_many :state_details
  
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  def environment
    unique_tf_state.split('-').last
  end

  def jenkins_job_name
    split_name = unique_tf_state.split('-')
    split_name.pop; split_name.shift
    split_name.join('-')
  end
end

class StateDetail < ActiveRecord::Base
  belongs_to :tfstate
  serialize :state_json, Hash
end

class TerraformSOA < Sinatra::Base
  register Sinatra::Twitter::Bootstrap::Assets
  register Sinatra::ActiveRecordExtension
  set :database_file, "../config/database.yml"
  set :public_folder, 'public'

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
      sha: Digest::SHA1.hexdigest(state.to_json)
      )
  end

  def create_tf_entry(state, raw_state, team, product, service, environment)
    unique_tf_state = "#{team}-#{product}-#{service}-#{environment}"
    db_transaction = find_unique_tf_state_entry(unique_tf_state)
    if db_transaction.nil?
      db_transaction = Tfstate.create(unique_tf_state: unique_tf_state, team: team)
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

  get '/' do
    @all_states = Tfstate.all
    erb :list_teams, layout: :main_layout
  end

  get '/all_states' do
    @all_states = Tfstate.all
    erb :list_states, layout: :main_layout
  end

  get '/list_team_states/:team' do
    @team = params[:team]
    @all_states = Tfstate.where(team: @team)
    erb :list_team_states, layout: :main_layout
  end

  get '/show/:unique_tf_state' do
    @state = Tfstate.where(unique_tf_state: params[:unique_tf_state]).first
    @team  = @state.team
    erb :show_state, layout: :main_layout
  end

  get '/show_state/:id' do
    @state_detail = StateDetail.find(params[:id])
    erb :show_state_detail, layout: :main_layout
  end

  get '/download_state/:id' do
    @state_detail = StateDetail.find(params[:id])
    attachment "#{@state_detail.tfstate.unique_tf_state}_#{@state_detail.created_at}.json"
    JSON.pretty_generate(@state_detail.state_json)
  end

  get '/render_graph/:state_detail_id' do
    state_detail = StateDetail.find(params[:state_detail_id])

    if !File.exist?("public/#{state_detail.tfstate.unique_tf_state}-#{state_detail.id}.png")
      digraph = state_detail.digraph
      File.open("/tmp/#{state_detail.tfstate.unique_tf_state}-#{state_detail.id}.dot", 'w') { |file| file.write(digraph) }
      `dot -Tpng /tmp/#{state_detail.tfstate.unique_tf_state}-#{state_detail.id}.dot -o public/#{state_detail.tfstate.unique_tf_state}-#{state_detail.id}.png`
    end
    redirect "/public/#{state_detail.tfstate.unique_tf_state}-#{state_detail.id}.png"
  end

  get '/changeset/:old_id/:new_id' do
    old, new = JSON.parse(StateDetail.find(params[:old_id]).state_json.to_json), JSON.parse(StateDetail.find(params[:new_id]).state_json.to_json)
    @diff = JSON.pretty_generate(JsonCompare.get_diff(old, new))
    erb :changeset, layout: :main_layout
  end

  # API Calls
  post '/tfsoa/add_tf_graph/:team/:product/:service/:environment/' do
    unique_tf_state = "#{params[:team]}-#{params[:product]}-#{params[:service]}-#{params[:environment]}"
    state_detail = Tfstate.where(unique_tf_state: unique_tf_state).first.state_details.last
    state_detail.update_attribute(:digraph, URI.unescape(request.body.read))
  end

  post '/tfsoa/add_tf_state/:team/:product/:service/:environment/' do
    # HTTP post TF state json to then endpoint
    @params = params
    create_tf_entry(JSON.parse(request.body.read), request.body.read, @params[:team], @params[:product],
      @params[:service], @params[:environment])
  end

end
