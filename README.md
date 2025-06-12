# CloudflareRailsRouter

A Rails gem that provides seamless integration with Cloudflare's API for managing routing rules, page rules, and worker routes directly from your Rails application.

## Features

- Manage Cloudflare Worker Routes
- Manage Cloudflare Page Rules
- Easy configuration via Rails credentials or environment variables
- Built-in retry logic for API calls
- Comprehensive error handling
- Rails generator for quick setup

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloudflare_rails_router'
```

And then execute:

```bash
bundle install
```

Run the installation generator:

```bash
rails generate cloudflare_rails_router:install
```

## Configuration

### Option 1: Using the Initializer

Configure the gem in `config/initializers/cloudflare_rails_router.rb`:

```ruby
CloudflareRailsRouter.configure do |config|
  # Use API Token (recommended)
  config.api_token = ENV["CLOUDFLARE_API_TOKEN"]
  
  # OR use API Key + Email
  # config.api_key = ENV["CLOUDFLARE_API_KEY"]
  # config.api_email = ENV["CLOUDFLARE_API_EMAIL"]
  
  # Required
  config.zone_id = ENV["CLOUDFLARE_ZONE_ID"]
  
  # Optional
  config.account_id = ENV["CLOUDFLARE_ACCOUNT_ID"]
  config.timeout = 30
  config.open_timeout = 10
  config.retry_count = 3
  config.retry_delay = 1
end
```

### Option 2: Using Rails Credentials

Add to your Rails credentials:

```yaml
cloudflare:
  api_token: your_token_here
  zone_id: your_zone_id_here
  account_id: your_account_id_here # optional
```

### Option 3: Environment Variables

The gem automatically loads from these environment variables:
- `CLOUDFLARE_API_TOKEN` (or `CLOUDFLARE_API_KEY` + `CLOUDFLARE_API_EMAIL`)
- `CLOUDFLARE_ZONE_ID`
- `CLOUDFLARE_ACCOUNT_ID` (optional)

## Usage

### Worker Routes

```ruby
# List all routes
routes = CloudflareRailsRouter.routes.list
routes[:routes].each do |route|
  puts "Pattern: #{route['pattern']}, Script: #{route['script']}"
end

# Create a new route
route = CloudflareRailsRouter.routes.create(
  pattern: "https://example.com/api/*",
  script: "api-worker"
)

# Get a specific route
route = CloudflareRailsRouter.routes.get(route_id)

# Update a route
CloudflareRailsRouter.routes.update(
  route_id,
  pattern: "https://example.com/api/v2/*",
  enabled: false
)

# Delete a route
CloudflareRailsRouter.routes.delete(route_id)

# Validate a pattern
is_valid = CloudflareRailsRouter.routes.validate_pattern("https://example.com/*")
```

### Page Rules

```ruby
# List all page rules
rules = CloudflareRailsRouter.page_rules.list

# Create a page rule
rule = CloudflareRailsRouter.page_rules.create(
  targets: "https://example.com/images/*",
  actions: [
    { id: "browser_cache_ttl", value: 14400 },
    { id: "edge_cache_ttl", value: 7200 }
  ],
  priority: 1,
  status: "active"
)

# Update a page rule
CloudflareRailsRouter.page_rules.update(
  rule_id,
  actions: [{ id: "browser_cache_ttl", value: 86400 }]
)

# Delete a page rule
CloudflareRailsRouter.page_rules.delete(rule_id)

# Update priorities
CloudflareRailsRouter.page_rules.update_priorities([
  { id: "rule1", priority: 1 },
  { id: "rule2", priority: 2 }
])
```

### Direct API Client

For other Cloudflare API endpoints:

```ruby
client = CloudflareRailsRouter.client

# GET request
response = client.get("/zones/#{zone_id}/dns_records")

# POST request
response = client.post("/zones/#{zone_id}/dns_records", {
  type: "A",
  name: "example.com",
  content: "192.0.2.1"
})

# PUT request
response = client.put("/zones/#{zone_id}/dns_records/#{record_id}", {
  content: "192.0.2.2"
})

# DELETE request
response = client.delete("/zones/#{zone_id}/dns_records/#{record_id}")
```

### Using Different Zone IDs

```ruby
# Use a different zone ID than the configured default
routes = CloudflareRailsRouter.routes(zone_id: "different-zone-id")
page_rules = CloudflareRailsRouter.page_rules(zone_id: "different-zone-id")
```

## Rake Tasks

```bash
# Verify your configuration
rake cloudflare:verify_config

# List all routes
rake cloudflare:routes

# List all page rules
rake cloudflare:page_rules
```

## Error Handling

The gem provides specific error types:

```ruby
begin
  CloudflareRailsRouter.routes.create(pattern: "invalid-pattern")
rescue CloudflareRailsRouter::ConfigurationError => e
  # Handle configuration errors (missing credentials, zone_id, etc.)
rescue CloudflareRailsRouter::ApiError => e
  # Handle Cloudflare API errors
  puts "Error: #{e.message}"
  puts "Status: #{e.status_code}"
  puts "Response: #{e.response_body}"
rescue CloudflareRailsRouter::NetworkError => e
  # Handle network-related errors
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kieranklaassen/cloudflare_rails_router. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kieranklaassen/cloudflare_rails_router/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CloudflareRailsRouter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kieranklaassen/cloudflare_rails_router/blob/main/CODE_OF_CONDUCT.md).