require 'securerandom'

module ForemanRhCloud
  class CloudConnector
    CLOUD_CONNECTOR_USER = 'cloud_connector_user'.freeze
    CLOUD_CONNECTOR_TOKEN_NAME = 'Cloud connector access token'.freeze
    CLOUD_CONNECTOR_FEATURE = 'ansible_configure_cloud_connector'.freeze

    def install
      user = service_user
      token_value = personal_access_token(user)
      target_host = foreman_host
      composer = nil

      input = {
        :cloud_connector_user => service_user.login,
        :cloud_connector_password => token_value,
      }

      if (http_proxy = ForemanRhCloud.proxy_setting(logger: Foreman::Logging.logger('app')))
        input[:cloud_connector_http_proxy] = http_proxy
      end

      Taxonomy.as_taxonomy(target_host.organization, target_host.location) do
        composer = ::JobInvocationComposer.for_feature(
          CLOUD_CONNECTOR_FEATURE,
          [target_host.id],
          input
        )
        composer.trigger!
      end

      composer.job_invocation
    end

    def latest_job
      feature_id = RemoteExecutionFeature.find_by_label(CLOUD_CONNECTOR_FEATURE)&.id
      return nil unless feature_id
      JobInvocation.where(:remote_execution_feature_id => feature_id).includes(:task).reorder('foreman_tasks_tasks.started_at DESC').first
    end

    def personal_access_token(user)
      access_token = PersonalAccessToken.find_by_name(CLOUD_CONNECTOR_TOKEN_NAME)

      access_token&.destroy! # destroy the old token if exists

      personal_access_token = PersonalAccessToken.new(:name => CLOUD_CONNECTOR_TOKEN_NAME, :user => user)
      token_value = personal_access_token.generate_token
      personal_access_token.save!

      token_value
    end

    def service_user
      user = User.find_by_login(CLOUD_CONNECTOR_USER)

      if user.nil?
        user = User.create!(
          :login => CLOUD_CONNECTOR_USER,
          :password => SecureRandom.base64(255),
          :description => "This is a service user used by cloud connector to talk to the Satellite API",
          :auth_source => AuthSourceInternal.first,
          :admin => true
        )
      end

      user
    end

    def foreman_host
      ForemanRhCloud.foreman_host
    end
  end
end
