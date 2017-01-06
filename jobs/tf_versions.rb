require_relative '../lib/tfsoa'

tf_versions = Array.new
tf_version_counts = Hash.new({ value: 0 })

# This should pick up the latest state_details for a given tfstates entry

# tf = Tfstate.all
# tf.each do |a| puts a.state_details.first.terraform_version end

# Grab the unique number of s3 bucket terraform states registered in DB
#SCHEDULER.every '10s' do
#end
