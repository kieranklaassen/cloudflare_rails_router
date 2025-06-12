# frozen_string_literal: true

require "cloudflare_rails_router"
require "webmock/rspec"
require "pry"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset configuration before each test
  config.before(:each) do
    CloudflareRailsRouter.reset_configuration!
  end

  # Allow localhost connections for WebMock
  WebMock.disable_net_connect!(allow_localhost: true)
end
