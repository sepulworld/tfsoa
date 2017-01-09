require_relative '../lib/tfsoa'
require 'active_support/all'

#TF States with 5 or more updates in last day hours
SCHEDULER.every '10s' do
  tf_states_with_changes = Hash.new 0
  tf_states_with_5_or_more_changes = Hash.new 0
  states = StateDetail.where(created_at: (Time.now.prev_day)..(Time.now))
  states.each do |state|
    tf_states_with_changes[Tfstate.where(
      id: state.tfstate_id).take.s3_bucket_key] += 1
  end
  tf_states_with_changes.each do |state, updates|
    if updates >= 5
      tf_states_with_5_or_more_changes[state] = { label: "#{state}",
                                                  value: updates }
    end
  end
  send_event('active_states',
    { items: tf_states_with_5_or_more_changes.values })
end
