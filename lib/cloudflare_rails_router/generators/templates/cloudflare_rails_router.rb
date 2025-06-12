# frozen_string_literal: true

CloudflareRailsRouter.configure do |config|
  # Authentication - Use either API Token (recommended) or API Key + Email
  
  # Option 1: API Token (recommended)
  # config.api_token = ENV["CLOUDFLARE_API_TOKEN"]
  
  # Option 2: API Key + Email
  # config.api_key = ENV["CLOUDFLARE_API_KEY"]
  # config.api_email = ENV["CLOUDFLARE_API_EMAIL"]
  
  # Required: Your Cloudflare Zone ID
  # config.zone_id = ENV["CLOUDFLARE_ZONE_ID"]
  
  # Optional: Your Cloudflare Account ID (required for some operations)
  # config.account_id = ENV["CLOUDFLARE_ACCOUNT_ID"]
  
  # Optional: Request timeout settings
  # config.timeout = 30        # Total request timeout in seconds
  # config.open_timeout = 10   # Connection open timeout in seconds
  
  # Optional: Retry settings
  # config.retry_count = 3     # Number of retries for failed requests
  # config.retry_delay = 1     # Initial delay between retries in seconds
end