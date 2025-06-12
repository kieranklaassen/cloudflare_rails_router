# frozen_string_literal: true

namespace :cloudflare do
  desc "List all Cloudflare routes for the configured zone"
  task routes: :environment do
    begin
      routes = CloudflareRailsRouter.routes.list
      
      if routes[:routes].empty?
        puts "No routes found for zone #{CloudflareRailsRouter.configuration.zone_id}"
      else
        puts "Routes for zone #{CloudflareRailsRouter.configuration.zone_id}:"
        puts "-" * 80
        
        routes[:routes].each do |route|
          puts "ID: #{route['id']}"
          puts "Pattern: #{route['pattern']}"
          puts "Script: #{route['script'] || 'None'}"
          puts "Enabled: #{route['enabled']}"
          puts "-" * 80
        end
        
        puts "\nTotal: #{routes[:total_count]} routes"
      end
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "List all Cloudflare page rules for the configured zone"
  task page_rules: :environment do
    begin
      rules = CloudflareRailsRouter.page_rules.list
      
      if rules.empty?
        puts "No page rules found for zone #{CloudflareRailsRouter.configuration.zone_id}"
      else
        puts "Page Rules for zone #{CloudflareRailsRouter.configuration.zone_id}:"
        puts "-" * 80
        
        rules.each do |rule|
          puts "ID: #{rule['id']}"
          puts "Priority: #{rule['priority']}"
          puts "Status: #{rule['status']}"
          puts "Targets:"
          rule['targets'].each do |target|
            puts "  - #{target['constraint']['value']}"
          end
          puts "Actions:"
          rule['actions'].each do |action|
            puts "  - #{action['id']}: #{action['value']}"
          end
          puts "-" * 80
        end
        
        puts "\nTotal: #{rules.size} page rules"
      end
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Verify Cloudflare configuration"
  task verify_config: :environment do
    config = CloudflareRailsRouter.configuration
    
    puts "Cloudflare Rails Router Configuration:"
    puts "-" * 40
    puts "API Token: #{config.api_token.present? ? '***' + config.api_token[-4..] : 'Not set'}"
    puts "API Key: #{config.api_key.present? ? '***' + config.api_key[-4..] : 'Not set'}"
    puts "API Email: #{config.api_email || 'Not set'}"
    puts "Zone ID: #{config.zone_id || 'Not set'}"
    puts "Account ID: #{config.account_id || 'Not set'}"
    puts "-" * 40
    
    if config.credentials_configured?
      puts "✓ Credentials are configured"
      
      # Try to make a test API call
      begin
        client = CloudflareRailsRouter.client
        response = client.get("/user/tokens/verify")
        puts "✓ API connection successful"
      rescue => e
        puts "✗ API connection failed: #{e.message}"
      end
    else
      puts "✗ Credentials are NOT configured"
      puts "\nPlease configure either:"
      puts "1. API Token (recommended)"
      puts "2. API Key + API Email"
    end
  end
end