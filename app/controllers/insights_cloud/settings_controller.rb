module InsightsCloud
  class SettingsController < ::ApplicationController
    def show
      render_setting(:insightsSyncEnabled, :allow_auto_insights_sync)
    end

    def update
      Setting[:allow_auto_insights_sync] = settings_params
      render_setting(:insightsSyncEnabled, :allow_auto_insights_sync)
    end

    def set_org_parameter
      parameter = params.require(:parameter)
      new_value = ActiveModel::Type::Boolean.new.cast(params.require(:value))
      org_id = params.require(:organization_id)

      organization = Organization.authorized.find(org_id)

      org_param = organization.organization_parameters.find_or_create_by(name: parameter) do |org_param|
        org_param.name = parameter
      end
      org_param.value = new_value
      org_param.save!
    end

    private

    def render_setting(node_name, setting)
      render json: {
        node_name => Setting[setting],
      }
    end

    def settings_params
      ActiveModel::Type::Boolean.new.cast(params.require(:insightsSyncEnabled))
    end
  end
end
