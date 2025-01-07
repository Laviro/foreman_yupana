class ChangeSyncInsightsRecommendationsToTrue < ActiveRecord::Migration[7.0]
  def change
    Setting.where(name: 'allow_auto_insights_sync')&.destroy_all
  end
end
