# frozen_string_literal: true

RSpec.describe CloudflareRailsRouter::Routes do
  let(:zone_id) { "test-zone-id" }
  let(:client) { instance_double(CloudflareRailsRouter::Client) }
  
  subject(:routes) { described_class.new(zone_id: zone_id, client: client) }

  describe "#initialize" do
    it "accepts zone_id and client" do
      expect(routes.zone_id).to eq(zone_id)
      expect(routes.client).to eq(client)
    end

    it "uses configuration zone_id by default" do
      CloudflareRailsRouter.configuration.zone_id = "config-zone"
      routes = described_class.new(client: client)
      expect(routes.zone_id).to eq("config-zone")
    end

    it "raises error when zone_id is not provided" do
      expect { described_class.new(client: client) }.to raise_error(
        CloudflareRailsRouter::ConfigurationError,
        "zone_id must be configured"
      )
    end
  end

  describe "#list" do
    let(:api_response) do
      {
        "success" => true,
        "result" => [
          {
            "id" => "route1",
            "pattern" => "https://example.com/*",
            "script" => "worker-script",
            "enabled" => true
          }
        ],
        "result_info" => {
          "page" => 1,
          "per_page" => 50,
          "total_count" => 1
        }
      }
    end

    it "lists all routes" do
      expect(client).to receive(:get)
        .with("/zones/#{zone_id}/workers/routes", { page: 1, per_page: 50 })
        .and_return(api_response)

      result = routes.list
      
      expect(result[:routes]).to have(1).item
      expect(result[:routes].first["id"]).to eq("route1")
      expect(result[:total_count]).to eq(1)
      expect(result[:page]).to eq(1)
      expect(result[:per_page]).to eq(50)
    end

    it "accepts pagination parameters" do
      expect(client).to receive(:get)
        .with("/zones/#{zone_id}/workers/routes", { page: 2, per_page: 100 })
        .and_return(api_response)

      routes.list(page: 2, per_page: 100)
    end
  end

  describe "#create" do
    it "creates a new route" do
      expect(client).to receive(:post)
        .with("/zones/#{zone_id}/workers/routes", {
          pattern: "https://example.com/api/*",
          script: "api-worker",
          enabled: true
        })
        .and_return({ "result" => { "id" => "new-route" } })

      result = routes.create(
        pattern: "https://example.com/api/*",
        script: "api-worker"
      )
      
      expect(result["id"]).to eq("new-route")
    end

    it "creates a route without script" do
      expect(client).to receive(:post)
        .with("/zones/#{zone_id}/workers/routes", {
          pattern: "https://example.com/static/*",
          enabled: true
        })
        .and_return({ "result" => { "id" => "new-route" } })

      routes.create(pattern: "https://example.com/static/*")
    end

    it "creates a disabled route" do
      expect(client).to receive(:post)
        .with("/zones/#{zone_id}/workers/routes", {
          pattern: "https://example.com/test/*",
          enabled: false
        })
        .and_return({ "result" => { "id" => "new-route" } })

      routes.create(pattern: "https://example.com/test/*", enabled: false)
    end
  end

  describe "#get" do
    it "retrieves a specific route" do
      route_id = "route123"
      expect(client).to receive(:get)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}")
        .and_return({ "result" => { "id" => route_id, "pattern" => "https://example.com/*" } })

      result = routes.get(route_id)
      expect(result["id"]).to eq(route_id)
    end
  end

  describe "#update" do
    let(:route_id) { "route123" }

    it "updates route pattern" do
      expect(client).to receive(:put)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}", {
          pattern: "https://example.com/new/*"
        })
        .and_return({ "result" => { "id" => route_id } })

      routes.update(route_id, pattern: "https://example.com/new/*")
    end

    it "updates route script" do
      expect(client).to receive(:put)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}", {
          script: "new-worker"
        })
        .and_return({ "result" => { "id" => route_id } })

      routes.update(route_id, script: "new-worker")
    end

    it "updates route enabled status" do
      expect(client).to receive(:put)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}", {
          enabled: false
        })
        .and_return({ "result" => { "id" => route_id } })

      routes.update(route_id, enabled: false)
    end

    it "updates multiple attributes" do
      expect(client).to receive(:put)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}", {
          pattern: "https://example.com/updated/*",
          script: "updated-worker",
          enabled: true
        })
        .and_return({ "result" => { "id" => route_id } })

      routes.update(
        route_id,
        pattern: "https://example.com/updated/*",
        script: "updated-worker",
        enabled: true
      )
    end
  end

  describe "#delete" do
    it "deletes a route" do
      route_id = "route123"
      expect(client).to receive(:delete)
        .with("/zones/#{zone_id}/workers/routes/#{route_id}")
        .and_return({ "success" => true })

      result = routes.delete(route_id)
      expect(result).to be true
    end
  end

  describe "#validate_pattern" do
    it "returns true for valid patterns" do
      expect(routes.validate_pattern("https://example.com/*")).to be true
      expect(routes.validate_pattern("http://example.com/api/*")).to be true
      expect(routes.validate_pattern("https://sub.example.com/path/*")).to be true
    end

    it "returns false for invalid patterns" do
      expect(routes.validate_pattern(nil)).to be false
      expect(routes.validate_pattern("")).to be false
      expect(routes.validate_pattern("example.com/*")).to be false
      expect(routes.validate_pattern("https://")).to be false
      expect(routes.validate_pattern("/path/*")).to be false
    end
  end
end