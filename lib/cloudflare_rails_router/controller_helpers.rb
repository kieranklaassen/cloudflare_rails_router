# frozen_string_literal: true

module CloudflareRailsRouter
  module ControllerHelpers
    def cloudflare_redirect_to(origin)
      config = CloudflareRailsRouter.configuration
      
      case origin
      when :marketing
        set_routing_cookie("marketing", config.cookie_ttl)
        redirect_to root_url(host: URI.parse(config.marketing_origin).host)
      when :app
        set_routing_cookie("app", config.cookie_ttl)
        redirect_to root_url
      end
    end

    private

    def set_routing_cookie(value, ttl)
      config = CloudflareRailsRouter.configuration
      cookies[config.cookie_name] = {
        value: value,
        expires: ttl.seconds.from_now,
        domain: config.cookie_domain,
        secure: Rails.env.production?,
        httponly: true
      }
    end
  end
end