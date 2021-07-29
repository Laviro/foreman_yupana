require 'rest-client'

module InsightsCloud
  module Async
    class InsightsResolutionsSync < ::Actions::EntryAction
      include ::ForemanRhCloud::CloudAuth

      RULE_ID_REGEX = /[^:]*:(?<id>.*)/

      def plan
        unless cloud_auth_available?
          logger.debug('Cloud authentication is not available, skipping resolutions sync')
          return
        end

        plan_self
      end

      def run
        InsightsResolution.transaction do
          InsightsResolution.delete_all
          api_response = query_insights_resolutions(relevant_rules)
          write_resolutions(api_response)
        end
      end

      def logger
        action_logger
      end

      private

      def query_insights_resolutions(rule_ids)
        resolutions_response = execute_cloud_request(
          method: :post,
          url: InsightsCloud.resolutions_url,
          headers: {
            content_type: :json,
          },
          payload: {
            issues: rule_ids,
          }.to_json
        )

        JSON.parse(resolutions_response)
      end

      def relevant_rules
        InsightsRule.all.pluck(:rule_id).map { |id| InsightsCloud.remediation_rule_id(id) }
      end

      def to_resolution_hash(rule_id, resolution_hash)
        {
          rule_id: rule_id,
          description: resolution_hash['description'],
          resolution_type: resolution_hash['id'],
          needs_reboot: resolution_hash['needs_reboot'],
          resolution_risk: resolution_hash['resolution_risk'],
        }
      end

      def write_resolutions(response)
        all_resolutions = response.map do |rule_id, rule_details|
          rule_details['resolutions'].map { |resolution| to_resolution_hash(to_rule_id(rule_id), resolution) }
        end.flatten

        InsightsResolution.create(all_resolutions)
      end

      def to_rule_id(resolution_rule_id)
        RULE_ID_REGEX.match(resolution_rule_id).named_captures.fetch('id', resolution_rule_id)
      end
    end
  end
end
