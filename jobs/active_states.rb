require_relative '../lib/tfsoa'
require 'active_support/all'

#TF States with 5 or more updates in last day hours
SCHEDULER.every '10s' do
  tf_states_with_changes_labelled = StateDetail.last(5).map {|a| {label: a.tfstate.unique_tf_state, value: a.created_at.strftime("%FT%R")}}
  send_event('active_states',
    { items: tf_states_with_changes_labelled })
end
