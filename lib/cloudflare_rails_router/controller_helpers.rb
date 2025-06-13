# frozen_string_literal: true

module CloudflareRailsRouter
  module ControllerHelpers
    def cloudflare_redirect_to(origin)
      config = CloudflareRailsRouter.configuration
      
      case origin
      when :marketing
        # Set the routing cookie to redirect to marketing
        cookies[config.cookie_name] = {
          value: "marketing",
          expires: config.cookie_ttl.seconds.from_now,
          domain: config.cookie_domain,
          secure: Rails.env.production?,
          httponly: true
        }
        redirect_to root_url(host: URI.parse(config.marketing_origin).host)
      when :app
        # Clear the routing cookie to go back to Rails (default)
        cookies.delete(config.cookie_name, domain: config.cookie_domain)
        redirect_to root_url
      end
    end
  end
end