# frozen_string_literal: true

require "spec_helper"
require "generators/cloudflare_rails_router/router/install_generator"

RSpec.describe CloudflareRailsRouter::Router::InstallGenerator, type: :generator do
  destination File.expand_path("../tmp", __dir__)
  
  before do
    prepare_destination
    run_generator
  end
  
  it "creates initializer file" do
    expect(file("config/initializers/cloudflare_rails_router.rb")).to exist
  end
  
  it "creates worker script" do
    expect(file("cloudflare/worker.js")).to exist
  end
  
  it "creates wrangler config" do
    expect(file("wrangler.toml")).to exist
  end
end