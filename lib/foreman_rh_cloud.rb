require 'foreman_rh_cloud/engine.rb'
require 'cgi'
require 'uri'

module ForemanRhCloud
  def self.on_premise_url
    return unless ForemanRhCloud.with_insights_on_premise?
    port = ENV['INSIGHTS_ADVISOR_PORT'] || "8000"
    "http://#{ForemanRhCloud.foreman_host.fqdn || 'localhost'}:#{port}"
  end

  def self.env_or_on_premise_url(env_var_name)
    ENV[env_var_name] || on_premise_url
  end

  def self.base_url
    # for testing set ENV to 'https://ci.cloud.redhat.com'
    @base_url ||= env_or_on_premise_url('SATELLITE_RH_CLOUD_URL') || 'https://cloud.redhat.com'
  end

  def self.cert_base_url
    @cert_base_url ||= env_or_on_premise_url('SATELLITE_CERT_RH_CLOUD_URL') || 'https://cert.cloud.redhat.com'
  end

  def self.legacy_insights_url
    @legacy_insights_url ||= env_or_on_premise_url('SATELLITE_LEGACY_INSIGHTS_URL') || 'https://cert-api.access.redhat.com'
  end

  def self.verify_ssl_method
    @verify_ssl_method ||= ENV['SATELLITE_RH_CLOUD_URL'] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
  end

  def self.query_limit
    @query_limit ||= ENV['SATELLITE_RH_CLOUD_QUERY_LIMIT'] ? ENV['SATELLITE_RH_CLOUD_QUERY_LIMIT'].to_i : 100
  end

  def self.http_proxy_string(logger: Foreman::Logging.logger('background'))
    ForemanRhCloud.proxy_setting(logger: logger)
  end

  def self.transformed_http_proxy_string(logger: Foreman::Logging.logger('background'))
    ForemanRhCloud.transform_scheme(ForemanRhCloud.proxy_setting(logger: logger))
  end

  def self.proxy_setting(logger: Foreman::Logging.logger('background'))
    fix_port(proxy_string(logger: logger))
  end

  def self.proxy_string(logger: Foreman::Logging.logger('background'))
    HttpProxy.default_global_content_proxy&.full_url ||
    ForemanRhCloud.cdn_proxy(logger: logger) ||
    ForemanRhCloud.global_foreman_proxy ||
    ''
  end

  def self.fix_port(uri_string)
    return '' if uri_string.empty?

    uri = URI(uri_string)
    uri.send(:define_singleton_method, :default_port, -> { nil })

    uri.to_s
  end

  def self.cdn_proxy(logger: Foreman::Logging.logger('app'))
    proxy_config = SETTINGS[:katello][:cdn_proxy]
    return nil unless proxy_config

    uri = URI('')
    uri.host = proxy_config[:host]
    uri.port = proxy_config[:port]
    uri.scheme = proxy_config[:scheme] || 'http'

    if proxy_config[:user]
      uri.user = CGI.escape(proxy_config[:user])
      uri.password = CGI.escape(proxy_config[:password])
    end
    uri.to_s
  rescue URI::Error => e
    logger.warn("cdn_proxy parsing failed: #{e}")
    nil
  end

  def self.global_foreman_proxy
    Setting[:http_proxy]
  end

  # This method assumes uri_string contains uri-encoded username and p@$$word:
  # http://user:p%40%24%24word@localhost:8888
  def self.transform_scheme(uri_string)
    return unless uri_string
    transformed_uri = URI.parse(uri_string)

    case transformed_uri.scheme
    when "http"
      transformed_uri.scheme = 'proxy'
    when "https"
      transformed_uri.scheme = 'proxys'
    end

    transformed_uri.to_s
  end

  # For testing purposes we can override the default hostname with an environment variable SATELLITE_RH_CLOUD_FOREMAN_HOST
  def self.foreman_host
    @foreman_host ||= begin
      fullname = foreman_host_name
      ::Host.unscoped.friendly.find(fullname)
    rescue ActiveRecord::RecordNotFound
      # fullname didn't work. Let's try shortname
      shortname = /(?<shortname>[^\.]*)\.?.*/.match(fullname)[:shortname]
      ::Host.unscoped.friendly.find(shortname)
    end
  end

  def self.foreman_host_name
    ENV['SATELLITE_RH_CLOUD_FOREMAN_HOST'] || marked_foreman_host&.name || ::SmartProxy.default_capsule.name
  end

  def self.marked_foreman_host
    ::Host.unscoped.search_for('infrastructure_facet.foreman = true').first
  rescue ScopedSearch::QueryNotSupported
    nil
  end

  def self.legacy_insights_ca
    "#{ForemanRhCloud::Engine.root}/config/rh_cert-api_chain.pem"
  end

  def self.cloud_url_validator
    @cloud_url_validator ||= Regexp.new(ENV['SATELLITE_RH_CLOUD_VALIDATOR'] || 'redhat.com$')
  end

  def self.requests_delay
    @requests_delay ||= ENV['SATELLITE_RH_CLOUD_REQUESTS_DELAY']
  end
end
