require_relative '../lib/tfsoa'

SCHEDULER.every '10s' do
  tf_state_count = Tfstate.select(:s3_bucket_key).distinct.count
  send_event('number_of_states', { current: tf_state_count })
end
