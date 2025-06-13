# frozen_string_literal: true

require "rails/generators/base"

module CloudflareRailsRouter
  module Router
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        template "cloudflare_rails_router.rb", "config/initializers/cloudflare_rails_router.rb"
      end

      def copy_worker_script
        template "cloudflare_worker.js", "cloudflare/worker.js"
      end

      def copy_wrangler_config
        template "wrangler.toml", "wrangler.toml"
      end

      def display_instructions
        say "\nCloudflare Rails Router installed!", :green
        say "\nNext steps:"
        say "1. Update config/initializers/cloudflare_rails_router.rb with your domains"
        say "2. Review and customize cloudflare/worker.js if needed"
        say "3. Update wrangler.toml with your Cloudflare account details"
        say "4. Deploy with: wrangler deploy"
      end
    end
  end
end