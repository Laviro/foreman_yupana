collection @hosts

attributes :name
node :insights_uuid do |host|
  host.insights_facet&.uuid
end
node :insights_hit_details do |host|
  host&.facts('insights::hit_details')&.values&.first
end
