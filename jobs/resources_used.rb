require_relative '../lib/tfsoa'
require 'active_support/all'

#TF States with 5 or more updates in last day hours
SCHEDULER.every '10s' do
  all_resources = Tfstate.all.map {|b| b.state_details.last.state_json['modules'].first['resources'].keys.map {|a| a.split('.').first}}.flatten
  counted_resources = all_resources.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| v }.reverse
  labelled_resources = counted_resources.map {|a| {label: a[0], value: a[1]}}
  
  send_event('resources_used',
    {
      items: labelled_resources
    }
  )
end
