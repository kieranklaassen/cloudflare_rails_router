# frozen_string_literal: true

module CloudflareRailsRouter
  class Configuration
    attr_accessor :app_origin, :marketing_origin, :cookie_name, 
                  :cookie_ttl, :cookie_domain, :crawlers_to,
                  :login_cookie_name

    def initialize
      @cookie_name = "cf_routing"
      @cookie_ttl = 30 * 60 # 30 minutes in seconds
      @crawlers_to = :marketing
      @login_cookie_name = "user_status"
    end
  end
end