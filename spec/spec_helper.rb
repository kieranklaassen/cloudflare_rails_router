# frozen_string_literal: true

require "bundler/setup"
require "cloudflare_rails_router"
require "rails"
require "rspec/rails"
require "generator_spec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end