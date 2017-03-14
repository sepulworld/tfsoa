require_relative '../lib/tfsoa'

SCHEDULER.every '10s' do
  tf = Tfstate.all
  tf_versions = Array.new
  tf_version_counts = Hash.new 0
  tf_version_labels = Hash.new({ value: 0 })
  tf.each do |state|
    tf_versions.push(state.state_details.first.terraform_version)
  end
  tf_versions.each do |count|
    tf_version_counts[count] += 1
  end
  tf_version_counts.each do |label, value|
    version = label
    tf_version_labels[version] = { label: "#{version || 'Unknown'}", value: value}
  end
  send_event('tf_versions', { items: tf_version_labels.values })
end
