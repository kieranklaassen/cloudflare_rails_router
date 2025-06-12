#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "cloudflare_rails_router"

# Example: Basic Usage of CloudflareRailsRouter

# Configure the gem
CloudflareRailsRouter.configure do |config|
  # You would normally use environment variables or Rails credentials
  config.api_token = ENV["CLOUDFLARE_API_TOKEN"] || "your-api-token"
  config.zone_id = ENV["CLOUDFLARE_ZONE_ID"] || "your-zone-id"
  
  # Optional settings
  config.timeout = 30
  config.retry_count = 3
end

# Example 1: Working with Routes
puts "=== Worker Routes Example ==="

begin
  # List all routes
  routes = CloudflareRailsRouter.routes.list
  puts "Total routes: #{routes[:total_count]}"
  
  routes[:routes].each do |route|
    puts "- Pattern: #{route['pattern']}, Script: #{route['script'] || 'None'}"
  end
  
  # Create a new route (example - would fail without valid credentials)
  # new_route = CloudflareRailsRouter.routes.create(
  #   pattern: "https://example.com/api/*",
  #   script: "api-worker"
  # )
  # puts "Created route: #{new_route['id']}"
  
rescue CloudflareRailsRouter::ConfigurationError => e
  puts "Configuration Error: #{e.message}"
rescue CloudflareRailsRouter::ApiError => e
  puts "API Error: #{e.message} (Status: #{e.status_code})"
rescue CloudflareRailsRouter::NetworkError => e
  puts "Network Error: #{e.message}"
end

# Example 2: Working with Page Rules
puts "\n=== Page Rules Example ==="

begin
  # List all page rules
  rules = CloudflareRailsRouter.page_rules.list
  puts "Total page rules: #{rules.size}"
  
  rules.each do |rule|
    puts "- Priority: #{rule['priority']}, Status: #{rule['status']}"
    rule['targets'].each do |target|
      puts "  Target: #{target['constraint']['value']}"
    end
  end
  
  # Create a page rule (example - would fail without valid credentials)
  # new_rule = CloudflareRailsRouter.page_rules.create(
  #   targets: "https://example.com/images/*",
  #   actions: [
  #     { id: "browser_cache_ttl", value: 14400 },
  #     { id: "edge_cache_ttl", value: 7200 }
  #   ],
  #   priority: 1
  # )
  # puts "Created page rule: #{new_rule['id']}"
  
rescue CloudflareRailsRouter::ConfigurationError => e
  puts "Configuration Error: #{e.message}"
rescue CloudflareRailsRouter::ApiError => e
  puts "API Error: #{e.message}"
rescue CloudflareRailsRouter::NetworkError => e
  puts "Network Error: #{e.message}"
end

# Example 3: Direct API Client Usage
puts "\n=== Direct API Client Example ==="

begin
  client = CloudflareRailsRouter.client
  
  # Example: Get zone details (would fail without valid credentials)
  # zone_id = CloudflareRailsRouter.configuration.zone_id
  # zone_details = client.get("/zones/#{zone_id}")
  # puts "Zone name: #{zone_details['result']['name']}"
  
  puts "Client configured with:"
  puts "- Timeout: #{CloudflareRailsRouter.configuration.timeout}s"
  puts "- Retry count: #{CloudflareRailsRouter.configuration.retry_count}"
  
rescue => e
  puts "Error: #{e.message}"
end

# Example 4: Pattern Validation
puts "\n=== Pattern Validation Example ==="

patterns = [
  "https://example.com/*",
  "http://example.com/api/*",
  "example.com/*",  # Invalid - missing protocol
  "/api/*",         # Invalid - missing domain
  ""                # Invalid - empty
]

patterns.each do |pattern|
  is_valid = CloudflareRailsRouter.routes.validate_pattern(pattern)
  puts "Pattern '#{pattern}' is #{is_valid ? 'valid' : 'invalid'}"
end