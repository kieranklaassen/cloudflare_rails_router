# frozen_string_literal: true

module CloudflareRailsRouter
  class Railtie < Rails::Railtie
    initializer "cloudflare_rails_router.configure" do |app|
      # Load configuration from Rails credentials or environment variables
      if app.credentials.respond_to?(:cloudflare) && app.credentials.cloudflare
        CloudflareRailsRouter.configure do |config|
          cloudflare_config = app.credentials.cloudflare
          
          config.api_token = cloudflare_config[:api_token]
          config.api_key = cloudflare_config[:api_key]
          config.api_email = cloudflare_config[:api_email]
          config.zone_id = cloudflare_config[:zone_id]
          config.account_id = cloudflare_config[:account_id]
        end
      elsif ENV["CLOUDFLARE_API_TOKEN"] || ENV["CLOUDFLARE_API_KEY"]
        CloudflareRailsRouter.configure do |config|
          config.api_token = ENV["CLOUDFLARE_API_TOKEN"]
          config.api_key = ENV["CLOUDFLARE_API_KEY"]
          config.api_email = ENV["CLOUDFLARE_API_EMAIL"]
          config.zone_id = ENV["CLOUDFLARE_ZONE_ID"]
          config.account_id = ENV["CLOUDFLARE_ACCOUNT_ID"]
        end
      end
    end

    # Add rake tasks
    rake_tasks do
      load File.expand_path("../tasks/cloudflare_rails_router.rake", __dir__)
    end

    # Add generators if needed
    generators do
      require "cloudflare_rails_router/generators/install_generator"
    end if defined?(Rails::Generators)
  end
end