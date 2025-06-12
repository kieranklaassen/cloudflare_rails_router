# frozen_string_literal: true

require_relative "cloudflare_rails_router/version"
require_relative "cloudflare_rails_router/configuration"
require_relative "cloudflare_rails_router/client"
require_relative "cloudflare_rails_router/routes"
require_relative "cloudflare_rails_router/page_rules"

require_relative "cloudflare_rails_router/railtie" if defined?(Rails::Railtie)

module CloudflareRailsRouter
  class Error < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Convenience methods
    def routes(zone_id: nil)
      Routes.new(zone_id: zone_id)
    end

    def page_rules(zone_id: nil)
      PageRules.new(zone_id: zone_id)
    end

    def client
      Client.new
    end
  end
end
