class AddUniqueIndexToRuleIdAndHostIdInInsightsHits < ActiveRecord::Migration[7.0]
  def change
    add_index :insights_hits, [:rule_id, :host_id], unique: true, name: 'index_insight_hits_on_rule_id_and_host_id'
  end
end
