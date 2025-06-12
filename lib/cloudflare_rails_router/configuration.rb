# frozen_string_literal: true

module CloudflareRailsRouter
  class Configuration
    attr_accessor :api_token, :api_key, :api_email, :zone_id, :account_id,
                  :timeout, :open_timeout, :retry_count, :retry_delay

    def initialize
      @timeout = 30
      @open_timeout = 10
      @retry_count = 3
      @retry_delay = 1
    end

    def credentials_configured?
      !api_token.to_s.empty? || (!api_key.to_s.empty? && !api_email.to_s.empty?)
    end

    def auth_headers
      if !api_token.to_s.empty?
        { "Authorization" => "Bearer #{api_token}" }
      elsif !api_key.to_s.empty? && !api_email.to_s.empty?
        {
          "X-Auth-Key" => api_key,
          "X-Auth-Email" => api_email
        }
      else
        raise ConfigurationError, "Cloudflare credentials not configured. Set either api_token or both api_key and api_email."
      end
    end
  end

  class ConfigurationError < StandardError; end
end