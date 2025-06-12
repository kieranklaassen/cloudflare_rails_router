# frozen_string_literal: true

RSpec.describe CloudflareRailsRouter do
  it "has a version number" do
    expect(CloudflareRailsRouter::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields the configuration object" do
      CloudflareRailsRouter.configure do |config|
        config.api_token = "test-token"
        config.zone_id = "test-zone"
      end

      expect(CloudflareRailsRouter.configuration.api_token).to eq("test-token")
      expect(CloudflareRailsRouter.configuration.zone_id).to eq("test-zone")
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration to defaults" do
      CloudflareRailsRouter.configure do |config|
        config.api_token = "test-token"
      end

      CloudflareRailsRouter.reset_configuration!

      expect(CloudflareRailsRouter.configuration.api_token).to be_nil
    end
  end

  describe ".routes" do
    it "returns a Routes instance" do
      CloudflareRailsRouter.configuration.zone_id = "test-zone"
      expect(CloudflareRailsRouter.routes).to be_a(CloudflareRailsRouter::Routes)
    end

    it "accepts a zone_id parameter" do
      routes = CloudflareRailsRouter.routes(zone_id: "custom-zone")
      expect(routes.zone_id).to eq("custom-zone")
    end
  end

  describe ".page_rules" do
    it "returns a PageRules instance" do
      CloudflareRailsRouter.configuration.zone_id = "test-zone"
      expect(CloudflareRailsRouter.page_rules).to be_a(CloudflareRailsRouter::PageRules)
    end

    it "accepts a zone_id parameter" do
      page_rules = CloudflareRailsRouter.page_rules(zone_id: "custom-zone")
      expect(page_rules.zone_id).to eq("custom-zone")
    end
  end

  describe ".client" do
    it "returns a Client instance" do
      expect(CloudflareRailsRouter.client).to be_a(CloudflareRailsRouter::Client)
    end
  end
end