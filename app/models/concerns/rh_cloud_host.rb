module RhCloudHost
  extend ActiveSupport::Concern

  included do
    has_many(
      :inventory_upload_facts,
      -> { where(fact_name_id: ForemanInventoryUpload::Generators::Queries.fact_names.values) },
      class_name: 'FactValue',
      foreign_key: :host_id
    )

    has_many :insights_hits, through: :insights, source: :hits
    scoped_search :relation => :insights, :on => :hits_count, :only_explicit => true, :rename => :insights_recommendations_count

    has_one :insights_client_report_status_object, :class_name => '::InsightsClientReportStatus', :foreign_key => 'host_id'
    scoped_search :relation => :insights_client_report_status_object, :on => :status, :rename => :insights_client_report_status,
      :complete_value => { :reporting => ::InsightsClientReportStatus::REPORTING,
                           :no_report => ::InsightsClientReportStatus::NO_REPORT }

    has_one :inventory_sync_status_object, :class_name => '::InventorySync::InventoryStatus', :foreign_key => 'host_id'
    scoped_search :relation => :inventory_sync_status_object, :on => :status, :rename => :insights_inventory_sync_status,
      :complete_value => { :disconnect => ::InventorySync::InventoryStatus::DISCONNECT,
                           :sync => ::InventorySync::InventoryStatus::SYNC }
    scoped_search :relation => :insights, :on => :uuid, :only_explicit => true, :rename => :insights_uuid

    def insights_facet
      insights
    end
  end
end
