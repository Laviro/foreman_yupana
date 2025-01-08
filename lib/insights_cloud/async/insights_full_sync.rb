require 'cgi'
require 'rest-client'

module InsightsCloud
  module Async
    class InsightsFullSync < ::Actions::EntryAction
      include ::ForemanRhCloud::CertAuth
      include ::ForemanRhCloud::Async::ExponentialBackoff

      def plan(organizations)
        organizations = organizations.select do |organization|
          if cert_auth_available?(organization)
            true
          else
            logger.debug("Certificate is not available for org: #{organization.name}, skipping insights sync")
            false
          end
        end

        sequence do
          # This can be turned off when we enable automatic status syncs
          # This step will query cloud inventory to retrieve inventory uuids for each host
          plan_hosts_sync(organizations)
          plan_self(organization_ids: organizations.map(&:id))
          concurrence do
            plan_rules_sync(organizations)
            plan_notifications
          end
        end
      end

      def try_execute
        organizations.each do |organization|
          unless cert_auth_available?(organization)
            logger.debug("Certificate is not available for org: #{organization.name}, skipping insights sync")
            next
          end

          perform_hits_sync(organization)
        end
        done!
      end

      def perform_hits_sync(organization)
        hits = query_insights_hits(organization)

        uuids = hits.map { |hit| hit['uuid'] }
        setup_host_ids(uuids, organization)

        replace_hits_data(hits, organization)
      end

      def logger
        action_logger
      end

      private

      def plan_hosts_sync(organizations)
        plan_action(InventorySync::Async::InventoryHostsSync, organizations)
      end

      def plan_rules_sync(organizations)
        plan_action(InsightsRulesSync, organizations)
      end

      def plan_notifications
        plan_action InsightsGenerateNotifications
      end

      def query_insights_hits(organization)
        hits_response = execute_cloud_request(
          organization: organization,
          method: :get,
          url: InsightsCloud.hits_export_url
        )

        JSON.parse(hits_response)
      end

      def query_insights_rules
        rules_response = execute_cloud_request(
          method: :get,
          url: InsightsCloud.rules_url
        )

        JSON.parse(rules_response)
      end

      def setup_host_ids(uuids, organization)
        @host_ids = Hash[
          InsightsFacet.for_organizations(organization.id).where(uuid: uuids).pluck(:uuid, :host_id)
        ]
      end

      def host_id(uuid)
        @host_ids[uuid]
      end

      def replace_hits_data(hits, organization)
        InsightsHit.transaction do
          # Reset hit counters to 0, they will be recreated later
          InsightsFacet.for_organizations(organization.id).update_all(hits_count: 0)
          InsightsHit.for_organizations(organization.id).delete_all
          InsightsHit.create(hits.map { |hits_hash| to_model_hash(hits_hash) }.compact)
        end
      end

      def to_model_hash(hit_hash)
        hit_host_id = host_id(hit_hash['uuid'])

        return unless hit_host_id

        {
          host_id: hit_host_id,
          last_seen: DateTime.parse(hit_hash['last_seen']),
          publish_date: DateTime.parse(hit_hash['publish_date']),
          title: hit_hash['title'],
          solution_url: hit_hash['solution_url'],
          total_risk: hit_hash['total_risk'].to_i,
          likelihood: hit_hash['likelihood'].to_i,
          results_url: hit_hash['results_url'],
          rule_id: to_rule_id(hit_hash['results_url']),
        }
      end

      def to_rule_id(results_url)
        CGI.unescape(safe_results_match(results_url)[:id] || '')
      end

      def safe_results_match(results_url)
        match = results_url.match(/\/(?<id>[^\/]*)\/[^\/]*\/\z/)

        match || { id: nil }
      end

      def rescue_strategy_for_self
        Dynflow::Action::Rescue::Fail
      end

      def organizations
        @organizations ||= Organization.where(id: input[:organization_ids])
      end
    end
  end
end
