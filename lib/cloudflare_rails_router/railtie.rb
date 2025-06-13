# frozen_string_literal: true

require "cloudflare_rails_router/controller_helpers"

module CloudflareRailsRouter
  class Railtie < ::Rails::Railtie
    initializer "cloudflare_rails_router.controller_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include CloudflareRailsRouter::ControllerHelpers
      end
    end

    generators do
      require "generators/cloudflare_rails_router/router/install_generator"
    end
  end
end