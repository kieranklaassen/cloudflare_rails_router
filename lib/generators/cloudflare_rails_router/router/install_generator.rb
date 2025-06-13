# frozen_string_literal: true

require "rails/generators/base"

module CloudflareRailsRouter
  module Router
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def gather_configuration
        say "\n🚀 Cloudflare Rails Router Setup", :blue
        say "=" * 50
        
        # Try to get app domain from Rails config or common patterns
        @app_domain = detect_app_domain
        @app_origin = "https://#{@app_domain}"
        
        say "\n📌 App domain: #{@app_domain}", :green
        unless yes?("Is this correct?", :yellow)
          @app_domain = ask("Enter your app domain (e.g., yourdomain.com):", :green)
          @app_origin = "https://#{@app_domain}"
        end
        
        # Marketing site
        @marketing_origin = ask("\n🎨 Enter your marketing site URL (e.g., https://marketing.webflow.io):", :green)
        
        # Smart defaults from domain
        @cookie_domain = ".#{@app_domain}"
        @cookie_name = "cf_routing"
        @worker_name = "#{@app_domain.gsub('.', '-')}-router"
        
        # Cloudflare configuration
        say "\n📋 Cloudflare Configuration", :blue
        say "Find these at: https://dash.cloudflare.com/#{@app_domain}", :cyan
        
        @account_id = ask("Account ID (right sidebar):", :green)
        @zone_id = ask("Zone ID (API section):", :green)
        
        @environment = "production"
      end
      
      private
      
      def detect_app_domain
        # Try multiple sources to detect domain
        domain = nil
        
        # Check Rails configuration files
        if defined?(Rails.application)
          # Check for common Rails settings
          domain ||= Rails.application.config.try(:action_mailer).try(:default_url_options).try(:[], :host)
          domain ||= Rails.application.config.try(:force_ssl_host)
          domain ||= Rails.application.config.try(:hosts)&.first
        end
        
        # Check for common environment variables
        domain ||= ENV['DOMAIN'] || ENV['APP_DOMAIN'] || ENV['HOST']
        
        # Default prompt
        domain || ask("Enter your app domain (e.g., yourdomain.com):", :green)
      end
      

      def copy_initializer
        template "cloudflare_rails_router.rb", "config/initializers/cloudflare_rails_router.rb"
      end

      def copy_worker_script
        template "cloudflare_worker.js", "cloudflare/worker.js"
      end

      def copy_wrangler_config
        template "wrangler.toml", "wrangler.toml"
      end

      def create_env_file
        create_file ".env.cloudflare" do
          <<~ENV
            CLOUDFLARE_ACCOUNT_ID=#{@account_id}
            CLOUDFLARE_ZONE_ID=#{@zone_id}
          ENV
        end
        
        append_to_file ".gitignore", "\n.env.cloudflare\n" if File.exist?(".gitignore")
      end

      def display_instructions
        say "\n✅ Cloudflare Rails Router installed!", :green
        say "=" * 50
        
        say "\n📝 Configuration:", :blue
        say "  • App: #{@app_origin}"
        say "  • Marketing: #{@marketing_origin}"
        say "  • Routing cookie: #{@cookie_name}"
        
        say "\n🚀 Deploy now:", :green
        say "  npm install -g wrangler  # if needed"
        say "  wrangler login          # if needed"
        say "  wrangler deploy"
        
        say "\n✨ That's it! Your router is ready to deploy.", :cyan
      end
    end
  end
end