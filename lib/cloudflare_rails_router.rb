# frozen_string_literal: true

require_relative "cloudflare_rails_router/version"
require_relative "cloudflare_rails_router/configuration"
require_relative "cloudflare_rails_router/railtie" if defined?(Rails)

module CloudflareRailsRouter
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end