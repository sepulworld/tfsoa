require_relative 'lib/tfsoa.rb'
require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :protection, :except => :path_traversal

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

# Map to API for adding states
map "/tfsoa" do
  run TerraformSOA.new
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
