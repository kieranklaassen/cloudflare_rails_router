# frozen_string_literal: true

require "spec_helper"

RSpec.describe CloudflareRailsRouter::Configuration do
  it "has default values" do
    config = described_class.new
    expect(config.cookie_name).to eq("cf_routing")
    expect(config.cookie_ttl).to eq(1800)
    expect(config.crawlers_to).to eq(:marketing)
  end
end