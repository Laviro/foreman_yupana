module Api
  module V2
    module RhCloud
      class AdvisorEngineConfigController < ::Api::V2::BaseController
        include ::Api::Version2

        api :GET, "/rh_cloud/advisor_engine_config", N_("Show if system is configured to use local Foreman Advisor Engine.")
        def show
          render json: {
            use_local_advisor_engine: ForemanRhCloud.with_local_advisor_engine?,
          }, status: :ok
        end
      end
    end
  end
end
