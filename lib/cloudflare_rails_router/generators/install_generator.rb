# frozen_string_literal: true

require "rails/generators/base"

module CloudflareRailsRouter
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a CloudflareRailsRouter initializer file."

      def copy_initializer
        template "cloudflare_rails_router.rb", "config/initializers/cloudflare_rails_router.rb"
      end

      def display_post_install_message
        readme "POST_INSTALL" if behavior == :invoke
      end
    end
  end
end