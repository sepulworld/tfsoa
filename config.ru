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
map "/" do
  run TerraformSOA.new
end

set :assets_prefix, '/dashboard/assets'
map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

map "/dashboard" do
  run Sinatra::Application
  set :default_dashboard, 'dashboard/tfstate'
end

map "/public" do
  run Rack::Directory.new("./public")
end
