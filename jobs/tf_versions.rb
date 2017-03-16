require_relative '../lib/tfsoa'

SCHEDULER.every '10s' do
  tf_states = Tfstate.all
  latest_versions = tf_states.map {|a| a.state_details.last.terraform_version}

  tf_versions = latest_versions.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{
     |k,v| v }.to_h.map {|k,v| {label: k || '< 0.7.0', value: v}}.reverse
  send_event('tf_versions', { items: tf_versions })
end
