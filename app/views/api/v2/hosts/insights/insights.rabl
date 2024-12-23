node :insights_attributes do
  partial 'api/v2/hosts/insights/base', object: @object&.insights_facet
end
