module ForemanHits
  module Async
    class Upload < ::Actions::EntryAction
      def plan(host, uuid, payload = {})
        plan_self(host_id: host.id, uuid: uuid, payload: payload)
      end

      def run
        host = Host.find(input[:host_id])
        payload = input[:payload]
        update_facets(host, input[:uuid])
        update_hits(host, payload)
        update_rules_and_resolutions(payload)
        update_details(host, payload)
      end

      def update_facets(host, uuid)
        InsightsFacet.find_or_create_by(host_id: host.id) do |facet|
          facet.uuid = uuid
        end
        host.reload
      end

      def update_hits(host, payload)
        facet = host.insights
        facet.hits.delete_all
        hits = payload[:hits]
        # rubocop:disable Rails/SkipsModelValidations
        facet.hits.insert_all(hits)
        facet.update(hits_count: facet.hits.count)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def update_rules_and_resolutions(payload)
        # rubocop:disable Rails/SkipsModelValidations
        ::InsightsRule.upsert_all(payload[:rules], unique_by: :rule_id)
        rules = payload[:rules].map { |rule| rule[:rule_id] }
        ::InsightsResolution.where(rule_id: rules).delete_all
        ::InsightsResolution.insert_all(payload[:resolutions])
        # rubocop:enable Rails/SkipsModelValidations
      end

      def update_details(host, payload)
        fact_name = FactName.where(name: "insights::hit_details", short_name: 'insights_details').first_or_create
        fact_value = host.fact_values.where(fact_name: fact_name).first_or_create
        fact_value.update(value: payload[:details])
      end

      def rescue_strategy_for_self
        Dynflow::Action::Rescue::Fail
      end
    end
  end
end
