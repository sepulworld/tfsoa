require_relative '../lib/tfsoa'

# Grab the unique number of s3 bucket terraform states registered in DB
SCHEDULER.every '10s' do
  tf_state_count = Tfstate.select(:unique_tf_state).distinct.count
  send_event('number_of_states', { current: tf_state_count })
end
