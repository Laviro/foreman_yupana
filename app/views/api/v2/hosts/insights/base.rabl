attributes :uuid

node :insights_hit_details do |facet|
  facet&.host&.facts('insights::hit_details')&.values&.first
end
