# Cloudflare Rails Router

Same‑domain edge routing between a Rails app and any marketing stack.

[![Gem Version](https://badge.fury.io/rb/cloudflare_rails_router.svg)](https://rubygems.org/gems/cloudflare_rails_router) [![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## Why?

- **One canonical domain** – visitors and crawlers only see `yourdomain.com`, boosting SEO and trust.
- **First‑party cookies** – referral and attribution data remain intact; no third‑party domains.
- **Zero redirects** – Cloudflare proxies directly; Core Web Vitals stay green.
- **Marketing agility** – content teams can ship landing pages on Webflow, Framer, or static hosting without touching Rails.
- **Edge decision** – cookie check happens at Cloudflare's POP; Rails isn't hit until needed.
- **SEO control** – optionally serve _all_ search‑engine requests from the marketing origin even while users hit the app.

---

## Installation

Add to your **Gemfile**:

```ruby
gem "cloudflare_rails_router"
```

Then run:

```bash
bundle install
```

### Requirements

- Rails 6.0+
- Cloudflare account with a configured domain
- Node.js (for Wrangler CLI)

---

## Quick Start

```bash
rails g cloudflare_rails_router:router:install   # Interactive setup wizard
wrangler deploy                                  # Deploy to Cloudflare
```

The generator will:
- Auto-detect your Rails app domain
- Ask for your marketing site URL  
- Request your Cloudflare Account & Zone IDs
- Generate all configuration files automatically

---

## Usage

### Redirect anonymous visitors to marketing

```ruby
class ApplicationController < ActionController::Base
  before_action :redirect_marketing! unless user_signed_in?

  private

  def redirect_marketing!
    cloudflare_redirect_to(:marketing)
  end
end
```

`cloudflare_redirect_to` relies on `marketing_origin` from your initializer—no string arguments needed.

```ruby
# config/initializers/cloudflare_rails_router.rb
CloudflareRailsRouter.configure do |c|
  c.app_origin = "https://yourdomain.com"
  c.marketing_origin = "https://marketing.framer.com"

  c.cookie_ttl = 10.minutes
  c.crawlers_to = :marketing
end
```

### Clearing/Refreshing the flag

The marketing cookie expires automatically after `cookie_ttl`. If you need to refresh it sooner you can add `?cm=1` to any URL on the Rails **app** origin. A cloudflare middleware will delete the cookie and continue the request normally (user ends up back in the app or redirected to marketing with any new cookies).

## How it Works

1. **Cloudflare Worker** - Runs on every request to your domain
2. **Dead Simple Logic**:
   - Crawlers → Always marketing (for SEO)
   - Cookie exists → Marketing site
   - No cookie → Rails app (default)
3. **You Control Everything** - Use `cloudflare_redirect_to(:marketing)` to set the cookie
4. **Seamless Experience** - No redirects, same domain throughout

## Configuration Options

```ruby
CloudflareRailsRouter.configure do |config|
  # Required: Your Rails app origin
  config.app_origin = "https://yourdomain.com"

  # Required: Your marketing site origin
  config.marketing_origin = "https://marketing.yourdomain.com"

  # Cookie name for routing decisions (default: "cf_routing")
  config.cookie_name = "cf_routing"

  # Cookie TTL in seconds (default: 30 minutes)
  config.cookie_ttl = 30 * 60

  # Cookie domain (e.g., ".yourdomain.com" for all subdomains)
  config.cookie_domain = ".yourdomain.com"

  # Routing cookie name (default: "cf_routing")
  config.cookie_name = "cf_routing"

  # Where to send crawlers (default: :marketing)
  config.crawlers_to = :marketing # or :app
end
```

## Cloudflare Setup

### Prerequisites

Install Wrangler (Cloudflare's CLI):
```bash
npm install -g wrangler
```

### Interactive Setup

Run the generator for a guided setup:
```bash
rails g cloudflare_rails_router:router:install
```

The wizard asks just 3 questions:
1. Your marketing site URL (e.g., https://marketing.webflow.io)
2. Your Cloudflare Account ID
3. Your Cloudflare Zone ID

Everything else is auto-detected or uses smart defaults.

### Deploy

After setup, deploy your worker:
```bash
wrangler login    # First time only
wrangler deploy   # Deploy to Cloudflare
```

### Manual Configuration

If you prefer manual setup, the generator creates these files:

**wrangler.toml**
```toml
name = "yourdomain-com-router"
main = "cloudflare/worker.js"
compatibility_date = "2024-01-01"
account_id = "your-account-id"

[env.production]
zone_id = "your-zone-id"
routes = [
  { pattern = "yourdomain.com/*", zone_name = "yourdomain.com" },
  { pattern = "www.yourdomain.com/*", zone_name = "yourdomain.com" }
]
```

## Testing

The gem includes RSpec tests for configuration and generator functionality:

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kieranklaassen/cloudflare_rails_router.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
